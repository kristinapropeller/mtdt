public with sharing class AutoTestSample {
    public static Integer addNumbers(Integer a, Integer b) {
        Integer left = (a == null) ? 0 : a;
        Integer right = (b == null) ? 0 : b;
        return left + right;
    }

    public static Boolean isPositive(Integer value) {
        return value != null && value > 0;
    }
}