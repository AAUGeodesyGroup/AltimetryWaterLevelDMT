% trimming text for CLMS data to be able to use json file
function text = json_trim(text)
MYLINES = splitlines(text);
%'    ]'
    j=length(MYLINES);
    minetext=char(string(MYLINES(j,1)));
    lookforward=string(MYLINES(j-1,1));
    while not( minetext(1)=='}') || not(lookforward == '    ]') 
    % while loop stops when the first symbol in minetext is '}' OR when lookforward is '    ]'
        j=j-1;
        minetext=char(string(MYLINES(j,1)));
        while minetext==""
            j=j-1;
            minetext=char(string(MYLINES(j,1)));
        end
        lookforward=string(MYLINES(j-1,1));
    end
    MYLINES=MYLINES(2:j);
    MYLINES(1)={'{'};
    MYLINES(length(MYLINES))={'}'};

    % Join lines into text
    text = strjoin(MYLINES);
end