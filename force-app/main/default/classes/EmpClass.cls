//business class
//develop
//Multi Org Delta SIT UAT
public class EmpClass {
    //Updated Meta.xml version
    //data members
    Integer eid,basic,hra,da,pf,tax,gross,netsal;
    String ename;
    //membermethods
    //1.create
    public EmpClass(){
        eid=0;
        basic=0;
        hra=0;
        da=0;
        pf=0;
        tax=0;
        gross=0;
        netsal=0;
    }
    //2.input
    public void setValues(Integer eno,String name,Integer bs,Integer hr,Integer d,Integer p,Integer tx){
        eid=eno;
     	ename=name;
    	basic=bs;
    	hra=hr;
    	da=d;
    	pf=p;
    	tax=tx;
    }
    //3.process
    public void grossSalary(){
        gross = basic+hra+da;
    }
    public void netSalary(){
        netsal = gross - (pf+tax);
    }
    //4.output
    public void getValues(){
        system.debug('the gross salary is'+ gross);
        system.debug('the net salary is'+ netsal);
    }
        
        
}