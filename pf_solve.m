function solvedvbus = pf_solve(yb,vbus,snet,slacklist,genlist,loadlist)%%  This routine solves the power flow problem using a Newton-Raphson%  iteration with ful Jacobian update at every iteration.%  %  Arguments: Complex bus admittance matrix, ybus;%             vector of complex bus voltage initial guess, vbus;%               NOTE: vbus must also carry the information of%               bus voltage magnituudes at PV buses - i.e., the%               initial magnitude will be maintained as the %               setpoint voltage;%             vector of net complex power demands, snet;%               NOTE: complex power generation will appear%               as a negative quantity in snet;%             real vectors slacklist,genlist,loadlist - these%               are lists containing the bus numbers of each%               type of bus.  For example, slacklist will%               contain a single element: the index of the slack bus.%%  Returns:   complex vector of bus voltage phasors that satisfy the%             power balance constraints to within a tolerance of 0.00005.%             %% Compute initial mismatch%fullmiss = pfmiss(yb,vbus,snet);  % mismatch at every bus%rmiss=[real(fullmiss(genlist));real(fullmiss(loadlist)); ...       imag(fullmiss(loadlist))];%% rmiss "selects" relevant mismatch components%error = max(abs(rmiss));  % pick off largest component of relevant mismatch%% Newton-Raphson Iterationloop_continue = 1; % This will be a flag for excessive # of iterationsitcnt = 0;%while (error > .00005 & loop_continue)    del=angle(vbus);    vmag=abs(vbus);    [dsdd, dsdv] = pflowjac(yb,vbus);%%   As with the mismatch, dsdd and dsdv will be all possible%   partial derivatives.  Below, rjac will pick off those elements%   relevant to our calculation%    rjac = [ ...         real(dsdd(genlist,genlist)) real(dsdd(genlist,loadlist)) ...         real(dsdv(genlist,loadlist)); ...%         real(dsdd(loadlist,genlist)) real(dsdd(loadlist,loadlist)) ...         real(dsdv(loadlist,loadlist)); ...%         imag(dsdd(loadlist,genlist)) imag(dsdd(loadlist,loadlist)) ...         imag(dsdv(loadlist,loadlist)) ];%%     dx =  - rjac\rmiss;  % Here is the actual update%%    Function call below re-assembles the vector of complex bus %    voltage phasors (vbus) from this update%     vbus = update(vbus,dx,genlist,loadlist);%%    Now check mismatch once again%     fullmiss = pfmiss(yb,vbus,snet); %      rmiss=[real(fullmiss(genlist));real(fullmiss(loadlist)); ...       imag(fullmiss(loadlist))];%     error = max(abs(rmiss));%     itcnt=itcnt+1;     if itcnt > 10       type noconvrg.msg        loop_continue = 0;     endendsolvedvbus=vbus;       