package com.example.monprojetspringboot;


import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class HelloController {

    @GetMapping("/bonjour")
    public String direBonjour() {
        return "Bonjour ! Mon premier projet Spring Boot";
    }
}
