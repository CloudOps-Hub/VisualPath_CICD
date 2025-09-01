//Test Manual Sonar
//Test Develop
//MergeConflict Resolution
//Checking new commits on open PR
@isTest
public class FirstClassTest {
    public static testmethod void main(){
        FirstClass obj = new FirstClass();//constructor method calling point
        obj.input(10, 20, 30);//calling point
        obj.process();
        obj.output();//calling point//PMD
    }
    public static testmethod void gain(){
        FirstClass obj = new FirstClass();
        obj.input(100, 200, 30);//calling point
        obj.process();
        obj.output();
    }
    public static testmethod void pain(){
        FirstClass obj = new FirstClass();
        obj.input(1000, 2000, 3000);//calling point
        obj.process();
        obj.output();
    }
}

//the adv of parameterised constructor is to reduce the of visits b/w b.cls and tst cls.