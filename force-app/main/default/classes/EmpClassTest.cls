//TEST
//Updated Meta.xml version
//MergeConflict Checking
@isTest
public class EmpClassTest {
    public static testmethod void main(){
        EmpClass obj = new EmpClass();
        obj.setValues(101,'ranjith',40000,10000,10000,5000,2000);
        obj.grossSalary();
        obj.netSalary();
        obj.getValues(); 
    }

}