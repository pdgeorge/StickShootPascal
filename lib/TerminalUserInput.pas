unit TerminalUserInput;
interface

	//
	// Writes the prompt for the user and then reads
	// and returns the string they enter.
	//
	function ReadString(prompt: String): String; //Why are you up here? Why do you have two "function ReadString()"? You confuse me!
	//Ahh That's why... So that the program can know "These are what we are dealing with"
	function ReadInteger(const prompt: String): Integer;

	function ReadIntegerRange(prompt: String; min, max: Integer): Integer;

implementation
uses SysUtils;

	function ReadString(prompt: String): String;
	begin
		Write(prompt);
		ReadLn(result);	//Question, doesn't this need a result?
		//Oh wait, I see it now... ReadLn goes directly into result.
	end;

	function ReadInteger(const prompt: String): Integer;

	var
		UserInput: String;
		CorrectInteger: Integer;
	begin
		Write(prompt);
		ReadLn(UserInput);
		While not TryStrToInt(UserInput, CorrectInteger) do
		begin
			Write('Please enter a whole number ');
			ReadLn(UserInput);
		end;
		result := CorrectInteger;
	end;

	function ReadIntegerRange(prompt: String; min, max: Integer):
	Integer;

	var
		num: Integer;

	begin
		num := ReadInteger(prompt);
		While (num < min) or (num > max) do
		begin
			WriteLn('Please enter a value between ', min, ' and ', max);
			num := ReadInteger(prompt);
		end;
		result := num;
	end;

end.