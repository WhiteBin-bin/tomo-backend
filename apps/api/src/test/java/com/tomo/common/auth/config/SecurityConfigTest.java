package com.tomo.common.auth.config;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@WebMvcTest(SecurityConfigTest.TestController.class)
@Import({SecurityConfig.class, SecurityConfigTest.TestController.class})
@ActiveProfiles("test")
class SecurityConfigTest {

  @Autowired private MockMvc mockMvc;

  @ParameterizedTest
  @ValueSource(
      strings = {
        "/scalar",
        "/scalar/",
        "/scalar/index.html",
        "/v3/api-docs",
        "/v3/api-docs/swagger-config",
        "/v3/api-docs.yaml"
      })
  @DisplayName("API 문서 GET 요청은 인증 없이 접근할 수 있다")
  void allowsDocumentation(String path) throws Exception {
    // when
    ResultActions result = mockMvc.perform(get(path));

    // then
    result.andExpect(status().isOk());
  }

  @Test
  @DisplayName("문서 이외의 경로는 비인증 요청에 로그인 화면 대신 401을 반환한다")
  void requiresAuthentication() throws Exception {
    // when
    ResultActions result = mockMvc.perform(get("/api/private"));

    // then
    result.andExpect(status().isUnauthorized());
  }

  @RestController
  static class TestController {

    @GetMapping({
      "/scalar",
      "/scalar/**",
      "/v3/api-docs",
      "/v3/api-docs/**",
      "/v3/api-docs.yaml",
      "/api/private"
    })
    String endpoint() {
      return "ok";
    }
  }
}
