class Page
{
	public var scroll:Int = 1;
	public var lastExpanded:Int = 0;//0 for never set, 1 for set to expanded, 2 for set to contracted
	public var mainText:String;
	public var titleText:String;
	public var simNumber:Int;
	
	public function new(titleText:String, mainText:String, simNumber:Int)
	{
		this.mainText = mainText;
		this.titleText = titleText;
		this.simNumber = simNumber;
	}
}
