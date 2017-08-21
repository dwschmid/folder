function [x_min, f_min, iter] = golden_section_search(f, a, b, epsilon, max_iter)

tau=double((sqrt(5)-1)/2);     

x1=a+(1-tau)*(b-a);            
x2=a+tau*(b-a);

f_x1=f(x1);        
f_x2=f(x2);



iter=0;                           

while ((abs(b-a)>epsilon) && (iter<max_iter))
    
    if(f_x1<f_x2)
        b=x2;
        x2=x1;
        x1=a+(1-tau)*(b-a);
        
        f_x1=f(x1);
        f_x2=f(x2);

    else
        a=x1;
        x1=x2;
        x2=a+tau*(b-a);
        
        f_x1=f(x1);
        f_x2=f(x2);
        
    end
    
    iter=iter+2;
end

if(f_x1<f_x2)
    x_min = x1;
    f_min = f_x1;        
else
    x_min = x2;
    f_min = f_x2;    
end

