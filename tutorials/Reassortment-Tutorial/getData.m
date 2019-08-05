%
ori = {'AgamP4';'AgamS1';'AcolM1';'AquaS1';'AaraD1';'AmelC2';'AmerM2';'AchrA1';'AepiE1'};
rep = {'AgamP4';'gam';'col';'qua';'ara';'mel';'mer';'anchr';'anepi'};
rep2 = {'P4';'S1';'M1';'S1';'D1';'C2';'M2';'A1';'E1'};

f = fopen('27loci.txt');
system('rm -r data');
system('mkdir data');
while ~feof(f)
    line = fgets(f);
    tmp = strsplit(line, '-');
    tmp2 = strsplit(tmp{2}, '"');
    fasta = fastaread(['/Users/nicmuell/Documents/github/IsolationWithMigration/Application/Gambia/data/maffilter/chr3L/chr3L-' tmp2{1} '.fa']);
    clear dat
    c = 1;
    for i = 1:length(fasta)
        if isempty(strfind(fasta(i).Header, 'AcolM1')) &&...
                isempty(strfind(fasta(i).Header, 'AepiE1'))  &&...
                isempty(strfind(fasta(i).Header, 'AgamP4'))  &&...
                isempty(strfind(fasta(i).Header, 'AchrA1'))  
            header_name_ind = find(ismember(ori,fasta(i).Header));
            dat(c) = fasta(i);
            dat(c).Header = [rep{header_name_ind} '_' rep2{header_name_ind}];
            c = c+1;
        end
    end
    nogap = true(1,length(dat(1).Sequence));
    for k = 1 : length(dat(1).Sequence)
        for l = 1 : length(dat)
            if strcmp(dat(l).Sequence(k),{'-'})
                nogap(k) = false;
                break;
            end 
        end
    end

    for l = 1 : length(dat)
        dat(l).Sequence = dat(l).Sequence(nogap);
    end

    fastawrite(['data/chr3L-' tmp2{1} '.fasta'],dat);
end
fclose(f);