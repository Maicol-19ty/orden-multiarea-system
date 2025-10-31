package com.multiarea.orderrouter;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:postgresql://localhost:5432/testdb",
    "spring.flyway.enabled=false"
})
class OrderRouterApplicationTests {

    @Test
    void contextLoads() {
    }

}
