package com.aliyuncs.aui.common.utils;


import com.aliyuncs.aui.common.exception.BizException;

import javax.validation.ConstraintViolation;
import javax.validation.Validation;
import javax.validation.Validator;
import java.util.Set;

/**
 * validator校验工具类
 */
public class ValidatorUtils {
    private static Validator validator;

    public static void validateEntity(Object object, Class<?>... groups)
            throws BizException {
        Set<ConstraintViolation<Object>> constraintViolations = validator.validate(object, groups);
        if (!constraintViolations.isEmpty()) {
            StringBuilder msg = new StringBuilder();
            for (ConstraintViolation<Object> constraint : constraintViolations) {
                msg.append(constraint.getMessage()).append("<br>");
            }
            throw new BizException(msg.toString());
        }
    }

    static {
        validator = Validation.buildDefaultValidatorFactory().getValidator();
    }

}
