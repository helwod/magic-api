package org.ssssssss.magicapi.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Minimal Spring Boot host that boots magic-api.
 * magic-api auto-configures itself once the starter is on the classpath;
 * no Controller/Service/Dao needed. Edit scripts at http://host:9999/magic/web
 */
@SpringBootApplication
public class MagicApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(MagicApiApplication.class, args);
    }
}
