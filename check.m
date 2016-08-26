function report = check(funcname)
    % [files, products] = matlab.codetools.requiredFilesAndProducts(funcname);

    text = fileread(funcname);
    tokens = tokenize(text);

    functions = functions(tokens);

    report = struct('functions', functions);
end

function functions = functions(tokens)
    beginnings = {'for' 'parfor' 'while' 'if' 'switch' 'classdef' ...
                  'events' 'properties' 'enumeration' 'methods' ...
                  'function'};

    functions = struct('name', {}, 'body', {}, 'indent', {});
    stack = struct('start', {}, 'indent', {});
    indent = 0;
    for pos = 1:length(tokens)
        token = tokens(pos);
        if strcmp(token.name, 'keyword') && any(strcmp(token.text, beginnings))
            indent = indent + 1;
        elseif strcmp(token.name, 'keyword') && strcmp(token.text, 'end')
            indent = indent - 1;
        end
        if strcmp(token.name, 'keyword') && strcmp(token.text, 'function')
            stack = [stack struct('start', pos, 'indent', indent-1)];
        elseif (strcmp(token.name, 'keyword') && strcmp(token.text, 'end') && ...
                ~isempty(stack) && indent == stack(end).indent)
            body = tokens(stack(end).start:pos);
            functions = [functions struct('name', get_funcname(body), ...
                                          'body', body, 'indent', stack(end).indent)];
            stack(end) = [];
        end
    end
end

function name = get_funcname(tokens)
    pos = search_token('pair', '(', tokens, 1, +1);
    pos = search_token('identifier', [], tokens, pos, -1);
    name = tokens(pos).text;
end

function pos = search_token(name, text, tokens, pos, increment)
    if ~isempty(name) && ~isempty(text)
        while ~( strcmp(tokens(pos).name, name) && strcmp(tokens(pos).text, text) )
            pos = pos + increment;
        end
    elseif ~isempty(text)
        while ~strcmp(tokens(pos).text, text)
            pos = pos + increment;
        end
    elseif ~isempty(name)
        while ~strcmp(tokens(pos).name, name)
            pos = pos + increment;
        end
    end
end
