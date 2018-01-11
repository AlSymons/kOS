IF SHIP:STATUS = "Prelaunch"
{
	RUNPATH("0:/BasicLauncher.ks",80000).
	RUNPATH("0:/KerbinMunTransfer.ks", 10000, true).
}
RUNPATH("0:/setboot"). //todo: remove after implementing boot persistence into in execnodeprecise.