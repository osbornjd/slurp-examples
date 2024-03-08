#include <fun4all/Fun4AllServer.h>
#include <fun4all/Fun4AllInputManager.h>
#include <fun4allraw/SinglePrdfInput.h>
#include <fun4allraw/SingleZdcInput.h>
#include <fun4allraw/Fun4AllPrdfInputManager.h>
#include <fun4allraw/Fun4AllPrdfInputPoolManager.h>
#include <fun4all/Fun4AllOutputManager.h>

#include <fun4allraw/Fun4AllEventOutputManager.h>

//#include <ffarawmodules/EventCombiner.h>
//#include <ffarawmodules/EventNumberCheck.h>

R__LOAD_LIBRARY(libfun4all.so)
R__LOAD_LIBRARY(libfun4allraw.so)
R__LOAD_LIBRARY(libffarawmodules.so)

void Fun4All_Combiner(int nEvents = 0,
		      const string &input_file00 = "seb00.list",
		      const string &input_file01 = "seb01.list",
		      const string &input_file02 = "seb02.list",
		      const string &input_file03 = "seb03.list",
		      const string &input_file04 = "seb04.list",
		      const string &input_file05 = "seb05.list",
		      const string &input_file06 = "seb06.list",
		      const string &input_file07 = "seb07.list",
		      const string &input_file08 = "hcalwest.list",
		      const string &input_file09 = "hcaleast.list",
		      const string &input_file10 = "zdc.list",
		      const string &input_file11 = "mbd.list",		      
		      const string &outputDir  = ".",
		      const string &outputName = "" )
{
 cout << input_file00 << endl;
 cout << input_file01 << endl;
 cout << input_file02 << endl;
 cout << input_file03 << endl;
 cout << input_file04 << endl;
 cout << input_file05 << endl;
 cout << input_file06 << endl;
 cout << input_file07 << endl;
 cout << input_file08 << endl;
 cout << input_file09 << endl;
 cout << input_file10 << endl;
 cout << input_file11 << endl;

  vector<string> infile;
  infile.push_back(input_file00);
  infile.push_back(input_file01);
  infile.push_back(input_file02);
  infile.push_back(input_file03);
  infile.push_back(input_file04);
  infile.push_back(input_file05);
  infile.push_back(input_file06);
  infile.push_back(input_file07);
  infile.push_back(input_file08);
  infile.push_back(input_file09);
//  infile.push_back(input_file10);

  Fun4AllServer *se = Fun4AllServer::instance();
  Fun4AllPrdfInputPoolManager *in = new Fun4AllPrdfInputPoolManager("Comb");
  //in->Verbosity(10);
  in->AddPrdfInputList(input_file11)->MakeReference(true);
  SingleZdcInput *zdcin = new SingleZdcInput("ZDCin",in);
  zdcin->AddListFile(input_file10);
  in->registerPrdfInput(zdcin);
  for (auto iter : infile)
  {
    in->AddPrdfInputList(iter);
  }

  se->registerInputManager(in);

//  EventNumberCheck *evtchk = new EventNumberCheck();
//  evtchk->MyPrdfNode("PRDF");
//  se->registerSubsystem(evtchk);

//  Fun4AllEventOutputManager *out = new Fun4AllEventOutputManager("EvtOut","/sphenix/lustre01/sphnxpro/commissioning/aligned/beam-%08d-%04d.prdf",20000);
//  Fun4AllEventOutputManager *out = new Fun4AllEventOutputManager("EvtOut","./beam_emcal-%08d-%04d.prdf",nGB*1000.0);
//  Fun4AllEventOutputManager *out = new Fun4AllEventOutputManager("EvtOut", outputDir+"/"+"beam_emcal-%08d-%04d.prdf",20000);
//  Fun4AllEventOutputManager *out = new Fun4AllEventOutputManager("EvtOut", outputDir + "/" + outputName + "-%08d-%04d.prdf",0,2000); /// 1GB=1000 last arg
  Fun4AllEventOutputManager *out = new Fun4AllEventOutputManager("EvtOut", outputName + "-%08d-%04d.prdf",0,2000); /// 1GB=1000 last arg
  out->Verbosity(10);
  //  out->SetNEvents(1000);                     // number of events per output file
  out->SetClosingScript("stageout.sh");      
  out->SetClosingScriptArgs(outputDir);  // additional beyond the name of the file

//"/sphenix/lustre01/sphnxpro/commissioning/aligned_v2/beam-%08d-%04d.prdf",0,2000);
//    out->DropPacket(21102);
  se->registerOutputManager(out);

  if (nEvents < 0) { return; }

  se->run(nEvents);

  se->End();
  delete se;
  gSystem->Exit(0);
}
