//Test Manual Sona
//public class
//Develop tesing
////MergeConflict Resolution
public class FirstClass {
    //data members
    Integer num1,num2, num3,result;//initially data members are null
    //member methods
    public FirstClass(){
        num1= 0;
        num2= 0;
        num3= 0;
    }
    //2.input
   public void input(Integer num1,Integer num2, Integer num3){
        this.num1 = num1;
        this.num2 = num2;//num 3 added
       	this.num3 = num3;
    }
    //3. process
    public void process(){
        //Integer result;//result is local variable
        result = num1+num2+num3;
        }
    //4. oputput
    public void output(){
        System.debug('the sum is' + result);//10  
    }

}