package com.tomo.database;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.sql.DataSource;
import org.flywaydb.core.Flyway;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.ImportAutoConfiguration;
import org.springframework.boot.autoconfigure.flyway.FlywayAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.ConfigurableApplicationContext;

/** 개발 DB에 마이그레이션을 적용하고 TLS 연결 및 재실행을 수동 검증하는 실행 도구. */
@TestConfiguration(proxyBeanMethods = false)
@ImportAutoConfiguration({DataSourceAutoConfiguration.class, FlywayAutoConfiguration.class})
public class DevDatabaseVerification {

  /**
   * dev 프로필의 DB 설정으로 연결하고 Flyway 검증 후 종료한다.
   *
   * @param args Spring 실행 인자
   * @throws Exception DB 연결 또는 검증 실패 시
   */
  public static void main(String[] args) throws Exception {
    try (ConfigurableApplicationContext context =
        new SpringApplicationBuilder(DevDatabaseVerification.class)
            .profiles("dev")
            .web(WebApplicationType.NONE)
            .run(args)) {
      DataSource dataSource = context.getBean(DataSource.class);
      try (Connection connection = dataSource.getConnection();
          Statement statement = connection.createStatement();
          ResultSet result = statement.executeQuery("SHOW SESSION STATUS LIKE 'Ssl_cipher'")) {
        if (!result.next() || result.getString(2).isBlank()) {
          throw new IllegalStateException("DB 연결에 TLS가 적용되지 않았습니다.");
        }
        System.out.println("TLS 연결 확인: " + result.getString(2));
      }

      Flyway flyway = context.getBean(Flyway.class);
      flyway.validate();
      if (flyway.migrate().migrationsExecuted != 0) {
        throw new IllegalStateException("재실행 시 추가 마이그레이션이 적용됐습니다.");
      }
      System.out.println("Flyway 검증 완료: 재실행 시 추가 적용 0건");
    }
  }
}
