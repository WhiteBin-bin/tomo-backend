package com.tomo.common.openapi;

import com.scalar.maven.core.ScalarProperties;
import com.scalar.maven.core.enums.ScalarTheme;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;

/** Scalar API 문서 화면에 Catppuccin 테마를 적용한다. */
@Configuration
@ConditionalOnProperty(name = "scalar.enabled", havingValue = "true")
public class ScalarConfig {

  /**
   * Spring 설정 바인딩이 끝난 Scalar 속성에 테마를 적용한다.
   *
   * @param themeResource Catppuccin 테마 CSS 리소스
   * @return Scalar 테마 후처리기
   * @throws IOException 테마 CSS를 읽지 못한 경우
   */
  @Bean
  public static BeanPostProcessor scalarThemePostProcessor(
      @Value("classpath:scalar/catppuccin.css") Resource themeResource) throws IOException {
    String customCss = themeResource.getContentAsString(StandardCharsets.UTF_8);
    return new BeanPostProcessor() {
      @Override
      public Object postProcessAfterInitialization(Object bean, String beanName) {
        if (bean instanceof ScalarProperties properties) {
          properties.setTheme(ScalarTheme.NONE);
          properties.setCustomCss(customCss);
        }
        return bean;
      }
    };
  }
}
