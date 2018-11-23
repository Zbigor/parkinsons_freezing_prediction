%% Define the walking blocks, turns and midswing indices
function [kinedata] = segment(kinedata) 
   
    % plot lumbar and select the absolut start and end point of movement
    
    if isfield(kinedata,'segment')
        return
    end
    
    meas(1).a = ['acc'];
    meas(2).a = ['gyr'];
    meas(3).a = ['mag'];
    t = kinedata.time;
    
    figure
    set(gcf,'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1])
    for mea = 1:3
        clear  y                 
        y = eval(sprintf('kinedata.lumbar.%s',meas(mea).a));                             
        ax(mea) = subplot(3,1,mea);        
        plot(t,y)
        legend('x','y','z')
        title(['lumbar ' meas(mea).a])                
    end 
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    linkaxes(ax,'x')
    [startx starty] = ginput(2);
    if startx(2) > t(end)
        startx(2) = t(end);
    end
    kinedata.segment.startend = startx;
    kinedata.segment.istartend = round(startx.*128);
    
   
    %% select turning points
    % from start to end point
    se = kinedata.segment.istartend;    
    a = kinedata.lumbar.mag(:,3);   
    
    mittel = (min(a(se(1):se(2)))+max(a(se(1):se(2))))/2;
    index1=find(a>mittel);
    index2=find(a<mittel);

    d1 = find(diff(index1) > 1);
    d2 = find(diff(index2) > 1);
    d1 = d1+1;
    d2 = d2+1;
    if index1(1) == 1
        turn(1) = t(index2(1));
        turn(end+1) = t(index1(end));
    else turn(1) = t(index1(1));
        turn(end+1) = t(index2(end)) ;   
    end
    
    turn = [turn t(index1(d1))];
    turn = [turn t(index2(d2))];
    turn = sort(turn);
   % delete turns before start and after ending and delete turns 
   % that have less than 3 seconds inbetween
    n = 0;
    for i = 1:length(turn(1,:))        
        xx = turn(1,i);
        if turn(1,i) < t(se(1)) 
            n = n+1;
            delturn(n) = i;
            continue
        elseif turn(1,i) > t(se(2))
            n = n+1;
            delturn(n) = i;
            continue            
        elseif xx < 4 
            n = n+1;
            delturn(n) = i;
            continue
        elseif xx > (kinedata.time(end)-4) 
            n = n+1;
            delturn(n) = i;
            continue
        end  
    end
    if exist('delturn','var') == 1
        for k = n:-1:1
            turn(delturn(k)) = [];
        end
    end
    % if 2 turns have less than 3 seconds distance, remove the second one
    k = 0;
    while k < length(turn(1,:))-1
        clear d
        k = k+1;
        d = turn(1,k) - turn(1,k+1);
        if abs(d) < 3
            turn(:,k+1) = [];
            k = k-1;
        end             
    end
    clear d k
    figure
    hold
    plot(t(index1),a(index1),'b');
    plot(t(index2), a(index2),'r');
    for k = 1:length(turn)
        line([turn(k) turn(k)],get(gca,'YLim'),'color','k')
    end
    hold on
    line([t(se(1)) t(se(1))],get(gca,'YLim'),'color','g','LineWidth',2)
    hold on 
    line([t(se(2)) t(se(2))],get(gca,'YLim'),'color','g','LineWidth',2)
    % look if the graph is correct, if yes press a key
    w = waitforbuttonpress;
    if w == 0
        disp('Button click')
    else
        disp('Key press')
    end   %% einbauen click with something: stop function
    
    clearvars -except kinedata meas se turn loadname
    turn(2:3,1:end) = 0;
    for k = 1:length(turn(1,:))  
        xx = turn(1,k);
        if xx+10 > kinedata.time(1,end)
            t = kinedata.time(1,end)-xx-0.5;
        elseif xx-10 <= 0
            t = xx-0.5;
        else t = 5;
        end
        figure
        set(gcf,'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1])
        for mea = 1:3
            clear x y yy
            x = kinedata.time(round(xx*128)-t*128:round(xx*128)+t*128);  
            yy = eval(sprintf('kinedata.lumbar.%s',meas(mea).a));
            y = yy(round(xx*128)-t*128:round(xx*128)+t*128,:);                
            ax(mea) = subplot(3,1,mea);        
            plot(x,y)
            legend('x','y','z')
            title(['lumbar ' meas(mea).a])                
        end
        set(gcf,'units','normalized','outerposition',[0 0 1 1]);
        linkaxes(ax,'x')
        [turnx turny] = ginput(2);
        turn(2:3,k) = turnx;
        close all
        clear xx turnx turny ax               
    end
    
    % add turn vector to kinedata structure
    kinedata.segment.turn = turn;
    

    %% segment steps
    clearvars -except kinedata loadname 
    foot(1).a = 'left';foot(2).a = 'right';
    %
    se = kinedata.segment.istartend;   
    for f = 1:2 % left and right        
        clearvars -except kinedata f foot loadname turn se
        a = eval(['kinedata.' num2str(foot(f).a) 'ankle.gyr(:,2)*180/pi']);
        clf
        plot(a,'b')
        hold
        zaehler = 0;
        sammle = 0;
        werte=[];
        mini=[];
        mini_t=[];
        for k=1:length(a)
            if a(k)<-50 
                if(zaehler==0)
                    line([k k], get(gca,'YLim'), 'color','r');
                end
                zaehler=zaehler + 1;
                % vector werte sammelt alle werte unter -50
                werte(zaehler) = a(k);
                sammle = 1;
            end
            if a(k)>-50 && sammle==1 
                line([k k], get(gca,'YLim'), 'color','g');
                sammle=0;
                % minimal value of werte 
                [val, idx] = min(werte);
                % save minimum value in 'mini'
                mini = [mini, val];
                % t-value of minimum value and save in mini_t
                min_t = k-zaehler+idx-1;
                % mini-t stores all t-values for mid-swing peak
                mini_t = [mini_t, min_t];
                line([min_t min_t], get(gca,'YLim'), 'color','k');
                werte=[];
                zaehler=0;
            end;
        end
        clear k
        for k = 1:length(mini_t);
            midswing(k) = kinedata.time(mini_t(k));
        end;
        % look for peaks less than 700 ms from each other and delete the smallest
        clear k
        n = 0;
        for k = 1:(length(midswing)-1)
            clear d
            d = midswing(k+1) - midswing(k);
            if d < 0.700
                clear p1* p2*
                n = n+1;
                %select largest peak
                p1_t = mini_t(k);  p2_t = mini_t(k+1);
                p1 = a(p1_t); p2 = a(p2_t);
                if p1 < p2
                    del(n) = k+1;            
                elseif p1 > p2
                    del(n) = k;            
                end
            end
        end
        clear k
        for k = n:-1:1
            midswing(del(k)) = []; mini_t(del(k)) = [];
        end
        clear del
        % only remain midswing points that lie between turn_begin(second
        % row) and turn_end(third row) of turn
        if isfield(kinedata.segment,'turn') == 1;
            turn = kinedata.segment.turn;
            n = 0;
            for k = 1:length(midswing) 
                if midswing(k) < turn(2,1) 
                    continue 
                end
                clear tur z
                tur = turn(2,:) - midswing(k);            
                [z] = find(tur == max(tur(tur < 0)));
                if midswing(k) > turn(3,z) % midswing is situated after turn completed
                    continue
                else n = n+1; del(n) = k;
                end           
            end
            clear k
            for k = n:-1:1
                midswing(del(k)) = []; mini_t(del(k)) = [];
            end
        end
        if isfield(kinedata.segment,'midswing_left') == 1
            eval(['kinedata.segment.midswing_' num2str(foot(f).a) '= [];'])
            eval(['kinedata.segment.imidswing_' num2str(foot(f).a) '= [];'])
        end
        eval(['kinedata.segment.midswing_' num2str(foot(f).a) '= midswing;'])
        eval(['kinedata.segment.imidswing_' num2str(foot(f).a) '= mini_t;'])
    end
    
    clearvars -except kinedata loadname turn 
    %% check if left and right is alternating
    se = kinedata.segment.istartend;  
    if isfield(kinedata.segment,'turn')
        nr = length(turn(1,:))+1;
    else
        nr = 0;
    end
    v = 0;
    while v <= nr
        v = v+1;
        clearvars -except v nr leftc rightc ileftc irightc kinedata turn se loadname
        if nr == 0
            t(1) = kinedata.time(se(1)); t(2) = kinedata.time(se(2));
            if t(1) > t(2)
                break 
            end
            l1 = kinedata.segment.midswing_left - t(1); 
            l2 = kinedata.segment.midswing_left - t(2); 
            r1 = kinedata.segment.midswing_right - t(1); 
            r2 = kinedata.segment.midswing_right - t(2); 
            if isempty(find(l1 > 0))
                disp(['no midswing values for left after ' num2str(t(2))])
                break
            elseif isempty(find(r1 > 0))
                disp(['no midswing values for right after ' num2str(t(2))])
                break
            end
            % find index for begin and end 
            [bl(1)] = find(l1 == min(l1(l1 > 0)));             
            [bl(2)] = find(l2 == max(l2(l2 < 0)));  
            [br(1)] = find(r1 == min(r1(r1 > 0)));             
            [br(2)] = find(r2 == max(r2(r2 < 0))); 
            
            left = kinedata.segment.midswing_left(bl(1):bl(2));
            right = kinedata.segment.midswing_right(br(1):br(2));
            ileft = kinedata.segment.imidswing_left(bl(1):bl(2));
            iright = kinedata.segment.imidswing_right(br(1):br(2));
            [kleft kright kileft kiright] = alternatemidswing(left,right,ileft,iright,v);
            leftc = kleft;rightc = kright;ileftc = kileft;irightc = kiright;
            clear kleft kright kileft kiright
        elseif v == 1;            
            t(1) = kinedata.time(se(1)); t(2) = kinedata.time(round(turn(2,1)*128));
            if t(1) > t(2)
                break 
            end
            l1 = kinedata.segment.midswing_left - t(1); 
            l2 = kinedata.segment.midswing_left - t(2); 
            r1 = kinedata.segment.midswing_right - t(1); 
            r2 = kinedata.segment.midswing_right - t(2); 
            if isempty(find(l1 > 0))
                disp(['no midswing values for left after ' num2str(turn(1,v))])
                break
            elseif isempty(find(r1 > 0))
                disp(['no midswing values for right after ' num2str(turn(1,v))])
                break
            end
            % find index for begin and end 
            [bl(1)] = find(l1 == min(l1(l1 > 0)));             
            [bl(2)] = find(l2 == max(l2(l2 < 0)));  
            [br(1)] = find(r1 == min(r1(r1 > 0)));             
            [br(2)] = find(r2 == max(r2(r2 < 0))); 
            
            left = kinedata.segment.midswing_left(bl(1):bl(2));
            right = kinedata.segment.midswing_right(br(1):br(2));
            ileft = kinedata.segment.imidswing_left(bl(1):bl(2));
            iright = kinedata.segment.imidswing_right(br(1):br(2));
            [kleft kright kileft kiright] = alternatemidswing(left,right,ileft,iright,v);
            leftc = kleft;rightc = kright;ileftc = kileft;irightc = kiright;
            clear kleft kright kileft kiright
        elseif v >= 2 && v < nr   
            clearvars -except v nr leftc rightc ileftc irightc kinedata turn se loadname
            t(1) = kinedata.time(round(turn(3,v-1)*128)); t(2) = kinedata.time(round(turn(2,v)*128));            
            if t(1) > t(2)
                break 
            end
            l1 = kinedata.segment.midswing_left - t(1); 
            l2 = kinedata.segment.midswing_left - t(2); 
            r1 = kinedata.segment.midswing_right - t(1); 
            r2 = kinedata.segment.midswing_right - t(2); 
            if isempty(find(l1 > 0)) 
                disp(['no midswing values after ' num2str(turn(1,v))])
                break
            elseif isempty(find(r1 > 0))
                disp(['no midswing values for right after ' num2str(turn(1,v))])
                break
            end
            % find index for begin and end 
            [bl(1)] = find(l1 == min(l1(l1 > 0)));             
            [bl(2)] = find(l2 == max(l2(l2 < 0)));  
            [br(1)] = find(r1 == min(r1(r1 > 0)));             
            [br(2)] = find(r2 == max(r2(r2 < 0))); 
            
            left = kinedata.segment.midswing_left(bl(1):bl(2));
            right = kinedata.segment.midswing_right(br(1):br(2));
            ileft = kinedata.segment.imidswing_left(bl(1):bl(2));
            iright = kinedata.segment.imidswing_right(br(1):br(2));
            [kleft kright kileft kiright] = alternatemidswing(left,right,ileft,iright,v);
            leftc = [leftc kleft]; rightc = [rightc kright];ileftc = [ileftc kileft]; irightc = [irightc kiright];
            clear kleft kright kileft kiright
        elseif v == nr
            clearvars -except v nr leftc rightc ileftc irightc kinedata turn se loadname
            t(1) = kinedata.time(round(turn(3,end)*128)); t(2) = kinedata.time(se(2)); 
            if t(1) > t(2)
                break 
            end
            l1 = kinedata.segment.midswing_left - t(1); 
            l2 = kinedata.segment.midswing_left - t(2); 
            r1 = kinedata.segment.midswing_right - t(1); 
            r2 = kinedata.segment.midswing_right - t(2); 
            if isempty(find(l1 > 0)) 
                disp(['no midswing values after ' num2str(turn(1,v-1))])
                break
            elseif isempty(find(r1 > 0)) 
                disp(['no midswing values after ' num2str(turn(1,v-1))])
                break
            end
            % find index for begin and end 
            [bl(1)] = find(l1 == min(l1(l1 > 0)));             
            [bl(2)] = find(l2 == max(l2(l2 < 0)));  
            [br(1)] = find(r1 == min(r1(r1 > 0)));             
            [br(2)] = find(r2 == max(r2(r2 < 0))); 
            
            left = kinedata.segment.midswing_left(bl(1):bl(2));
            right = kinedata.segment.midswing_right(br(1):br(2));
            ileft = kinedata.segment.imidswing_left(bl(1):bl(2));
            iright = kinedata.segment.imidswing_right(br(1):br(2));
            if isempty(left) || isempty(right)
                continue
            else
                [kleft kright kileft kiright] = alternatemidswing(left,right,ileft,iright,v);
                leftc = [leftc kleft]; rightc = [rightc kright];ileftc = [ileftc kileft]; irightc = [irightc kiright];
                clear kleft kright kileft kiright
            end            
        end
    end
    % plot new and old midswing in subplot, click wenn ok
    l = kinedata.segment.midswing_left;r = kinedata.segment.midswing_right;
    figure    
    hold on;     
    subplot(2,1,1)
    title('new')
    for i = 1:length(leftc);
        line([leftc(i) leftc(i)],[0 1],'color','k');
        hold on
    end
    for i = 1:length(rightc);
        line([rightc(i) rightc(i)],[0 1],'color','r');
        hold on
    end
    subplot(2,1,2)    
    title('old')
    for i = 1:length(l);
        line([l(i) l(i)],[0 1],'color','k');
        hold on
    end
    for i = 1:length(r)
        line([r(i) r(i)],[0 1],'color','r');
        hold on
    end
    w = waitforbuttonpress;
    if w == 0
        disp('Button click')
    else
        disp('Key press')
    end  
    kinedata.segment.midswing_left = [];kinedata.segment.midswing_left = leftc;
    kinedata.segment.midswing_right = [];kinedata.segment.midswing_right = rightc;
    kinedata.segment.imidswing_left = [];kinedata.segment.imidswing_left = ileftc;
    kinedata.segment.imidswing_right = [];kinedata.segment.imidswing_right = irightc;       
    
    close all
end
    

