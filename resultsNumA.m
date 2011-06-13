function sn_ndx = resultsNumA(flag, soa)
    
    global exp 
    
    soa = [20 40 80 160];
    
    path_r = '/Users/petavision/neuro_comp/exp/numbers/2afc/numA/';
    mask_lab = dir([path_r 'data/masks/*.png']);
    left = dir([path_r 'data/left/*.png']);
    right = dir([path_r 'data/right/*.png']);
    
    addpath([path_r 'results/official']);
    files = dir([path_r 'results/official/*.mat']);
    len = length(files);
    
    num = 2;
    dist = 2;
    trials = 576; 
    %        num_cmp = zeros(rows, num_masks,2);
    %mask_ndx = cell(2,num_masks);

    S = {'E'; 'h'};
    %mask_types = cellstr(S);

    S2 = [2 4];
    %numbers = cellstr(S2);
    masks = {'1','7','r','5','A','8'};

    rows = trials *2;
    %rows = length(exp.choice);


%     score = struct( ...
%         'num', zeros(num,1), ...
%         'mask', zeros(length(masks),1), ...
%         'soa', zeros(length(soa),1), ...
%         'sm', zeros(length(soa), length(masks)), ...
%         'sn', zeros(len, length(soa), length(masks), num, dist));


    sn = zeros(length(soa), length(masks), num, dist, len);
    num_label = zeros(rows,1);
    dist_label = cell(rows,1);
    num_ndx = cell(num,1);

    soa_label = zeros(rows,1);
    soa_ndx = cell(4,1);
    sn_ndx = cell(length(soa), length(masks), num, dist, len);
    sm_ndx = cell(length(soa), length(masks));



    for pt = 1:len

        load(files(pt).name)

        %len = length(exp.target_flag);
        %r = zeros(rows, 1);


        r = exp.target_flag - exp.choice;

        % number correct
        c = length(find(r == 0));

        % number of type 1 errors
        type1 = length(find(r == -1));

        % number of type 2 errors
        type2 = length(find(r == 1));

        % percent correct
        pc = c / (c+type1+type2);


        block = 1;

        mask_char = cell(rows,1);
        mask_ndx = cell(size(mask_char));

        for i = 1:rows
            if ischar(left(i).name)
                trial = mod(i,trials)+1;

                if mod(i, trials) == 0 && i < 1100
                    block = block + 1;
                end

                ndx = exp.ndxB(block)*trials+exp.ndxT(trial,block);

                if isempty(str2num(left(ndx).name(12)))
                    num_label(i) = str2num(right(ndx).name(10));
                    dist_label{i} = left(ndx).name(12);
                else
                    num_label(i) = str2num(left(ndx).name(12));
                    dist_label{i} = right(ndx).name(10);
                end

                soa_char = left(ndx).name(10);

                mask_char{i} = mask_lab(ndx).name(11);

                %             if sum(strcmp(num_char,numbers)) == 1
                %                 num_label(i) = str2num(num_char);
                %             else

                %                 count = str2num(exp.pairs{i,1}(5:8));
                %                 j = 1;
                %                 while count > 120*j
                %                     j = j + 1;
                %                 end
                % %                 %disp(['count: ', num2str(count),'  j: ',num2str(j-1)]);
                %                 num_label(i) = j-1;
                %             end

                soa_label(i) = str2num(soa_char);
            end
        end
%{
        for k = 1:num
            %i = k+1;
            num_ndx{k} = find(num_label == S2(k));
            if ~isempty(num_ndx{k})
                score.num(k) = sum(r(num_ndx{k}) == 0) / (sum(r(num_ndx{k}) == 0) ...
                    + sum(r(num_ndx{k}) == 1) + sum(r(num_ndx{k}) == -1));
            end
        end

        for i = 1:4
            soa_ndx{i} = find(soa_label == i);
            if ~isempty(soa_ndx{i})
                score.soa(i) = sum(r(soa_ndx{i}) == 0) / (sum(r(soa_ndx{i}) == 0) ...
                    + sum(r(soa_ndx{i}) == 1) + sum(r(soa_ndx{i}) == -1));
            end
        end

        for i = 1:length(masks)
            mask_ndx{i} = find(strcmp(mask_char, masks{i}));
            if ~isempty(mask_ndx{i})
                score.mask(i) = sum(r(mask_ndx{i}) == 0) / (sum(r(mask_ndx{i}) == 0) ...
                    + sum(r(mask_ndx{i}) == 1) + sum(r(mask_ndx{i}) == -1));
            end
        end

        for i = 1:length(soa)
            for j = 1:length(masks)
                sm_ndx{i,j} = r(soa_label == i & strcmp(mask_char, masks{j}));
                score.sm(i,j) = sum(sm_ndx{i,j} == 0) / (sum(sm_ndx{i,j} ...
                    == 0) + ...
                    sum(sm_ndx{i,j} == ...
                    1) + ...
                    sum(sm_ndx{i,j} == ...
                    -1));
            end
        end
%}
        for i = 1:length(soa)
            for j = 1:length(masks)
                for k = 1:num
                    for ii = 1:dist
                        sn_ndx{i,j,k,ii,pt} = r(soa_label == i & strcmp(mask_char, masks{j}) & ...
                            num_label == S2(k) & strcmp(dist_label,S{ii}));
                            sn(i,j,k,ii,pt) = sum(sn_ndx{i,j,k,ii} == 0) / (sum(sn_ndx{i,j,k,ii} ...
                            == 0) + ...
                            sum(sn_ndx{i,j,k,ii} == ...
                            1) + ...
                            sum(sn_ndx{i,j,k,ii} == ...
                            -1));
                    end
                end
            end
        end
    end
%{
        sm_ = score.sm';
        sn_2 = score.sn(:,:,1)';
        sn_4 = score.sn(:,:,2)';
        stack_sn = zeros(size(sn_));
        stack_sm = zeros(size(sm_));
        [rws cls] = size(sm_);

        for i = 1:rws
            for j = 1:cls
                x = rws-i+1;
                y = cls-j+1;
                y1 = cls-j;
                if y1 > 0
                    stack_sm(x,y) = sm_(x,y)-sm_(x,y1);
                else
                    stack_sm(x,y) = sm_(x,y);
                end
            end
        end

        [rws cls] = size(sn_);
	
	for i = 1:rws
	  for j = 1:cls
	    x = rws-i+1;
	    y = cls-j+1;
	    y1 = cls-j;
	    if y1 > 0
	      stack_sn(x,y) = sn_(x,y)-sn_(x,y1);
	    else
	      stack_sn(x,y) = sn_(x,y);
	    end
	  end
	end

	figure, bar(stack_sm,'stack');
	set(gca, 'XTickLabel', masks);
        title('mask score');

        figure, bar([2 4], stack_sn, 'stack');
	set(gca,'xlim', [-1 10]);
        title('number score');
	figure
	if flag
	  [m eb] = resultsNumAll(false);
	  errorbar(soa,m,eb);  
	  hold on
	end

	plot(soa, score.soa,':.');
	set(gca,'xlim' ,[soa(1)-10 soa(4)+10]);
	title('soa score')
	
        %}
%end