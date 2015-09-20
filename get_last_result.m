function [data] = get_last_result (name)

data = csvread([name '/output.csv']);

end