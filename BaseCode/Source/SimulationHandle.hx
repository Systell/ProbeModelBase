package;//FOR SCRIPTED EDITING: LINE 10 AND 22 ARE THE LINES TO DYNAMICALLY INPUT THE CLASSES; MAKE SURE THEY ALL EXTEND SIMULATION! THE BASIC TEMPLATE FOR A NEW SIMULATION PROJECT SHOULD INCLUDE A SIMULATION CLASS, A MAIN CLASS THAT IS JUST A DUMMY THAT LINKS TO A CLASS THAT HAS THE NAME OF THE DIRECTORY WHICH CONTAINS A BUNCH OF OVERRIDES (SEE DELETE FOR EXAMPLES)

import openfl.display.*;
import openfl.Lib;

class SimulationHandle
{
	public var s:Stage;
	public var sims:Array<Dynamic> =[
	DELETE1, DELETE2, DELETE1, DELETE2
	];
	public var currentPriority = 0;
	public var timePerFrame = 15;
	public var precomputeComplete:Bool = false;
	public var simCompute:Int = 0;
	public var allMaxed:Bool = false;
	
	public var currentSim = 0;
	public function new (s:Stage)
	{
		this.s = s;
		sims[0] = new DELETE1(s, Main.calibrationFactor);sims[1] = new DELETE2(s, Main.calibrationFactor);sims[2] = new DELETE1(s, Main.calibrationFactor);sims[3] = new DELETE2(s, Main.calibrationFactor);
	}
	public function run(frameBeginTime:Int)
	{
		//sims[currentSim].enterFrame();
		while(timePerFrame-(Lib.getTimer()-frameBeginTime)>1 && !precomputeComplete)
		{
			if(simCompute > sims.length-1)
			{
				simCompute = 0;
				currentPriority++;
				if(allMaxed)
				{
					precomputeComplete = true;
					break;
				}
				
			}
			allMaxed = true;
			var completed = true;
			if(currentPriority<=sims[simCompute].maxPriority)
			completed = sims[simCompute].precompute(currentPriority, Lib.getTimer()-frameBeginTime);
			if(!completed || sims[simCompute].maxPriority > currentPriority)
			allMaxed = false;
			if(!completed)
			break;
			simCompute++;
		}
	}
	public function newSimulation(newSim:Int)
	{
		if(currentSim != -1)
		sims[currentSim].deactivate();
		if(newSim != -1)
		sims[newSim].activate();
		currentSim = newSim;
	}
}
