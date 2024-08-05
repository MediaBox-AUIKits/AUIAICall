package com.alivc.auicommon.core.assist;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * @author puke
 * @version 2021/9/9
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Property {

    String tips() default "";

    String defaultValue() default "";

    String options() default "";

    boolean rebootIfChanged() default true;

    boolean hideDefaultText() default false;
}
