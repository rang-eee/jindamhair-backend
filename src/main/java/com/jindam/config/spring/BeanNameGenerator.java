package com.jindam.config.spring;

import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.context.annotation.AnnotationBeanNameGenerator;

/**
 * datasource가 다른 같은 mapper 사용을 위한 bean name custom 추가
 */
public class BeanNameGenerator extends AnnotationBeanNameGenerator {
    @Override
    protected String buildDefaultBeanName(BeanDefinition definition) {
        String className = definition.getBeanClassName();
        return className != null ? className.replace(".", "_") : super.buildDefaultBeanName(definition);
    }
}