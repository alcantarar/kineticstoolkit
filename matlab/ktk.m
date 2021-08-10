% Matlab helper functions for reading and writing Kinetics Toolkit files
% (.ktk.zip)
%
% Copyright 2020-2021 Félix Chénier
%
% Licensed under the Apache License, Version 2.0 (the "License");
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
%
% __author__ = "Félix Chénier"
% __copyright__ = "Copyright (C) 2020-2021 Félix Chénier"
% __email__ = "chenier.felix@uqam.ca"
% __license__ = "Apache 2.0"


classdef ktk
    
    methods (Static, Access='private')
        
        function variable = pyconvert(variable)
            % Convert a complex structure into a JSON-encodable structure.
            
            if isa(variable, 'struct')
                theFields = fields(variable);
                new_variable = struct();
                for iField = 1:length(theFields)
                    theField = theFields{iField};
                    new_variable.(theField) = ...
                        ktk.pyconvert(variable.(theField));
                end
                variable = new_variable;
                
            elseif isa(variable, 'double')
                new_variable = struct();
                new_variable.class__ = 'numpy.array';
                new_variable.value = variable;
                variable = new_variable;
                
            elseif numel(variable) > 1
                new_variable = variable;
                for element = 1:numel(variable)
                    new_variable(element) = ...
                        ktk.pyconvert(variable(element));
                end
                variable = new_variable;
                
            elseif isa(variable, 'timeseries')
                new_variable = struct();
                new_variable.class__ = 'matlab.timeseries';
                new_variable.time = variable.Time;
                new_variable.data = variable.Data;
                
                nEvents = length(variable.Events);
                new_variable.events = [];
                for iEvent = 1:nEvents
                    new_variable.Events(iEvent).name = ...
                        variable.Events(iEvent).Name;
                    new_variable.Events(iEvent).time = ...
                        variable.Events(iEvent).Time;
                end
                variable = ktk.pyconvert(new_variable);
                
            end
            
        end
        
    end
    
    methods (Static)        
        
        function [data, metadata] = load(filename)
            % Load a .ktk.zip file
            %
            % Parameters
            % ----------
            % filename: character array.
            %    The name of the file.
            %
            % Returns
            % -------
            % data: The saved data
            % metadata: The metadata for the saved data
            %
            % Important
            % ---------
            % These Matlab's ktk.load() and ktk.save() functions are built
            % only to ease data exchange between different research labs.
            %
            % Due to different types supported by Kinetics Toolkit and
            % Matlab, some information is lost during the save operation.
            % Consequently, using ktk.load() to load a ktk.zip file that
            % was saved using ktk.save() will not fully reconstruct the
            % original variable. Do not use ktk.load() and ktk.save() back
            % and forth between python and Matlab, this will only lead to
            % lots of headaches.
            try
                mkdir('temp-ktk-load')
            end
            unzip(filename, 'temp-ktk-load');
            data = jsondecode(fileread('temp-ktk-load/data.json'));
            metadata = jsondecode(fileread('temp-ktk-load/metadata.json'));
            rmdir('temp-ktk-load', 's')
            
        end
        
        function save(filename, variable)
            % Save a variable to a .ktk.zip file
            %
            % Parameters
            % ----------
            % filename: character array.
            %    The name of the file.
            % variable: any type.
            %    The variable to save.
            %
            % Returns
            % -------
            % Nothing
            %
            % Important
            % ---------
            % These Matlab's ktk.load() and ktk.save() functions are built
            % only to ease data exchange between different research labs.
            %
            % Due to different types supported by Kinetics Toolkit and
            % Matlab, some information is lost during the save operation.
            % Consequently, using ktk.load() to load a ktk.zip file that
            % was saved using ktk.save() will not fully reconstruct the
            % original variable. Do not use ktk.load() and ktk.save() back
            % and forth between python and Matlab, this will only lead to
            % lots of headaches.
            
            if exist('metadata.json', 'file')
                error('Cannot save in a folder that contains a file named metadata.json')
            end
            if exist('data.json', 'file')
                error('Cannot save in a folder that contains a file named data.json')
            end
            
            contents = ktk.pyconvert(variable);
            metadata = struct();
            metadata.Software = 'Kinetics Toolkit - Matlab wrapper';
            metadata.Version = 'Unknown';
            metadata.SaveDate = date();
            
            date_time = datetime();
            metadata.SaveTime = ...
                int2str(date_time.Hour) + ':' + ...
                int2str(date_time.Minute) + ':' + ...
                int2str(date_time.Second);
                
            metadata.Computer = computer();
            metadata.User = ...
                char(java.lang.System.getProperty('user.name'));

            encoded_metadata = jsonencode(metadata);
            encoded_contents = jsonencode(contents);

            fid = fopen('metadata.json', 'w');
            fprintf(fid, '%s', encoded_metadata);
            fclose(fid);

            fid = fopen('data.json', 'w');
            fprintf(fid, '%s', encoded_contents);
            fclose(fid);

            zip(filename, {'metadata.json', 'data.json'});
            
            delete('metadata.json')
            delete('data.json')
            
        end
        
    end
end