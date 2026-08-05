/**
 * The getInstance method takes a funcName string parameter and returns
 * an instance of the pp_Func class for that function name.
*/
public class pp_Funcs {
    public static pp_Func getInstance(String funcName) {
        return getInstance(funcName, 'No Func Type with Name: ' + funcName);
    }

    public static pp_Func getInstance(String funcName, String errorMessage) {
        Type funcType = Type.forName(funcName);
        if (funcType == null) {
            throw new GetFuncException(errorMessage);
        }

        pp_Func funcVar = (pp_Func)funcType.newInstance();
        if (funcVar == null) {
            throw new GetFuncException('Unable to create Func instance of type name: ' + funcName);
        }
        return funcVar;
    }

    public class GetFuncException extends Exception {
    }
}