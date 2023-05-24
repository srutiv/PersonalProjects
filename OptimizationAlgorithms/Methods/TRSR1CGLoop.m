% Code written by: Sruti Vutukury
% Algorithm theory discussed in "Numerical Optimization", J.Nocedal

function [x,f,outputs] = TRSR1CGLoop(problem,method,options)
    %{
    SR1 quasi-Newto Trust-Region Method with CG subproblem solver
    Algorithm 6.2 from Numerical Optimization, Nocedal
    Inputs: problem, method, options (structs)
    Outputs: final iterate (x), final function value (f)
    %}

    % compute initial function, gradient
    fc = 0; %counts how many function evaluations
    gc = 0; %counts how many gradient evaluations
    hc = 0; %counts how many hessian evaluations
    x = problem.x0;
    f = problem.compute_f(x); fc = fc + 1;
    g = problem.compute_g(x); gc = gc + 1;
    g0 = g;
    B = eye(problem.n); %use an approximation of the Hessian
    delta = method.delta0;
    xhold = [];
    fhold = [];

    % set initial iteration counter
    tic
    tstart = cputime; %start timer to measure performance
    k = 0;
    while (k < options.max_iterations) && (norm(g,"inf") > 1e-6*max(norm(g0,"inf"),1)) && (toc < options.time_limit)
       
        %%%%% get step sk via solving TR subproblem with CG, Algo 7.2
        s = CG_subproblem_solver(g,B,delta,problem,options);

        %%%%% TR iteration update, Algo 6.2, Nocedal
        f_new = problem.compute_f(x+s); fc = fc + 1;
        g_new = problem.compute_g(x+s); gc = gc + 1;
        
        y = g_new-g;
        ared = f - f_new; %actual reduction
        pred = -(g'*s+0.5*s'*B*s); %predicted reduction
        if (ared/pred) > method.eta
            x_new = x + s;
        else
            x_new = x;
        end

        if (ared/pred) > 0.75
            if norm(s,2) <= 0.8*delta
                %don't update delta
            else
                delta = 2*delta;
            end
        elseif (0.1 <= ared/pred) &&  (ared/pred <= 0.75)
            %don't update delta
        else
            delta = 0.5*delta;
        end
        if abs(s'*(y-B*s)) >= method.r*norm(s,2)*norm(y-B*s,2) %condition 6.26
            %B = B + ((y-B*s)*(y-B*s)')/((y-B*s)'*s); %B_(k+1) upate based on 6.24
            %H = H + (s-H*y)*(s-H*y)'/(s-H*y)'*y; %inverse Hessian approximation
        else
            %don't update B
        end
        
        % iteration updates
        x = x_new;
        f = f_new;
        g = g_new;
        xhold = [xhold x];
        fhold = [fhold f];
        k = k + 1;

    end %end iteration k
    
    %final outputs after termination
    outputs.xhold = xhold;
    outputs.fhold = fhold;
    outputs.k = k; %iterations
    outputs.time = tstart-cputime; %time to find a solution
    outputs.evals = 0; %total number of gradient and hessian evaluations
    outputs.fc = fc; %number of function evaluations
    outputs.gc = gc; %number of gradient evaluations
    outputs.hc = hc; %number of hessian evaluations
end

function pk = CG_subproblem_solver(g,H,delta,problem,options)
    %{
    solve the TR subproblem approximately --> pk, Algorithm 7.2, Numerical Optimization, Nocedal
    inputs: gradient g, Hessian H
    outputs: step length pk
    %}

    zj = zeros(problem.n,1); %iterate generated by CG solver
    rj = g; %parameter 
    dj = -g; %search direction
    Bk = H; %Hessian
    epsk = norm(g,2); %termination tolerance for CG
    found = false; %did not find a pk, continue j loop

    if norm(rj,2) < epsk
        pk = zeros(problem.n,1);
        found = true;
    else
        j= 0;
        while j < options.max_iterations && ~found %if a pk is found, leave CG solver
            if (dj'*Bk)*dj <= 0
                % stops the method if its current search direction
                % dj is a direction of nonpositive curvature along Bk
                % squared pk = zj + tau*dj and took positive root to find tau
                num = -2*zj'*dj + sqrt((2*zj'*dj)^2-4*(dj'*dj)*(zj'*zj-delta^2));
                den = 2*(dj'*dj);
                tau = num/den;
                pk = zj + tau*dj;
                found = true;
            end

            alphaj = (rj'*rj)/((dj'*Bk)*dj);
            zjp1 = zj + alphaj*dj;
            %zjp1 = sum(alphaj*dj);
            
            if norm(zjp1,2) >= delta
                % stops the method if zj+1 violates the trust-region bound
                num = -2*zj'*dj + sqrt((2*zj'*dj)^2-4*(dj'*dj)*(zj'*zj-delta^2));
                den = 2*(dj'*dj);
                tau = num/den;
                pk = zj + tau*dj;
                found = true;
            end

            rjp1 = rj + alphaj*Bk*dj;
            if norm(rjp1,2) <= epsk
                pk = zjp1;
                found = true;
            end

            zj = zjp1;
            betajp1 = (rjp1'*rjp1)/(rj'*rj);
            rj = rjp1;
            djp1 = -rjp1 + betajp1*dj;
            dj = djp1;
            j  = j+1;
        end %end j iters 
    end
    if found == false
        check1 = 1; % shouldn't happen, might need to increase max_iterations
        pk = zeros(problem.n,1);
    end
end