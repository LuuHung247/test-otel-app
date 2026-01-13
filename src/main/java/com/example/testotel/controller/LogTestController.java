package com.example.testotel.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@RestController
@RequestMapping("/api")
public class LogTestController {
    
    private static final Logger logger = LoggerFactory.getLogger(LogTestController.class);
    private final Random random = new Random();
    
    @GetMapping("/hello")
    public Map<String, String> hello() {
        logger.info("Hello endpoint called at {}", LocalDateTime.now());
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Hello from OpenTelemetry Test App!");
        response.put("timestamp", LocalDateTime.now().toString());
        
        return response;
    }
    
    @GetMapping("/logs/all")
    public Map<String, String> generateAllLogs() {
        logger.trace("TRACE level log - very detailed information");
        logger.debug("DEBUG level log - debugging information");
        logger.info("INFO level log - general information");
        logger.warn("WARN level log - warning message");
        logger.error("ERROR level log - error occurred");
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Generated logs at all levels");
        response.put("timestamp", LocalDateTime.now().toString());
        
        return response;
    }
    
    @GetMapping("/logs/random")
    public Map<String, String> generateRandomLog() {
        int level = random.nextInt(5);
        
        switch (level) {
            case 0:
                logger.trace("Random TRACE log - value: {}", random.nextInt(100));
                break;
            case 1:
                logger.debug("Random DEBUG log - value: {}", random.nextInt(100));
                break;
            case 2:
                logger.info("Random INFO log - value: {}", random.nextInt(100));
                break;
            case 3:
                logger.warn("Random WARN log - value: {}", random.nextInt(100));
                break;
            case 4:
                logger.error("Random ERROR log - value: {}", random.nextInt(100));
                break;
        }
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Generated random log");
        response.put("level", getLevelName(level));
        response.put("timestamp", LocalDateTime.now().toString());
        
        return response;
    }
    
    @PostMapping("/logs/custom")
    public Map<String, String> customLog(@RequestParam String level, @RequestParam String message) {
        switch (level.toUpperCase()) {
            case "TRACE":
                logger.trace("Custom log: {}", message);
                break;
            case "DEBUG":
                logger.debug("Custom log: {}", message);
                break;
            case "INFO":
                logger.info("Custom log: {}", message);
                break;
            case "WARN":
                logger.warn("Custom log: {}", message);
                break;
            case "ERROR":
                logger.error("Custom log: {}", message);
                break;
            default:
                logger.info("Custom log (default): {}", message);
        }
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Custom log generated");
        response.put("level", level);
        response.put("content", message);
        response.put("timestamp", LocalDateTime.now().toString());
        
        return response;
    }
    
    @GetMapping("/simulate/error")
    public Map<String, String> simulateError() {
        try {
            // Simulate an error
            int result = 10 / 0;
        } catch (Exception e) {
            logger.error("Simulated error occurred", e);
        }
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Error simulated and logged");
        response.put("timestamp", LocalDateTime.now().toString());
        
        return response;
    }
    
    @GetMapping("/simulate/traffic")
    public Map<String, String> simulateTraffic(@RequestParam(defaultValue = "10") int count) {
        logger.info("Simulating {} log entries", count);
        
        for (int i = 0; i < count; i++) {
            int level = random.nextInt(5);
            String logMessage = String.format("Simulated log entry #%d with random value: %d", 
                i + 1, random.nextInt(1000));
            
            switch (level) {
                case 0:
                    logger.trace(logMessage);
                    break;
                case 1:
                    logger.debug(logMessage);
                    break;
                case 2:
                    logger.info(logMessage);
                    break;
                case 3:
                    logger.warn(logMessage);
                    break;
                case 4:
                    logger.error(logMessage);
                    break;
            }
        }
        
        Map<String, String> response = new HashMap<>();
        response.put("message", String.format("Generated %d log entries", count));
        response.put("timestamp", LocalDateTime.now().toString());
        
        return response;
    }
    
    private String getLevelName(int level) {
        switch (level) {
            case 0: return "TRACE";
            case 1: return "DEBUG";
            case 2: return "INFO";
            case 3: return "WARN";
            case 4: return "ERROR";
            default: return "UNKNOWN";
        }
    }
}
