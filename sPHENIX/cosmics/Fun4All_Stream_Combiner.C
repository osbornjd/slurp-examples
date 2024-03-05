#include <fun4all/Fun4AllDstOutputManager.h>
#include <fun4all/Fun4AllInputManager.h>
#include <fun4all/Fun4AllOutputManager.h>
#include <fun4all/Fun4AllServer.h>
#include <fun4allraw/Fun4AllStreamingInputManager.h>
#include <fun4allraw/InputManagerType.h>
#include <fun4allraw/SingleGl1PoolInput.h>
#include <fun4allraw/SingleInttPoolInput.h>
#include <fun4allraw/SingleMicromegasPoolInput.h>
#include <fun4allraw/SingleMvtxPoolInput.h>
#include <fun4allraw/SingleTpcPoolInput.h>

#include <phool/recoConsts.h>

#include <ffarawmodules/InttCheck.h>
#include <ffarawmodules/StreamingCheck.h>
#include <ffarawmodules/TpcCheck.h>

R__LOAD_LIBRARY(libfun4all.so)
R__LOAD_LIBRARY(libfun4allraw.so)
R__LOAD_LIBRARY(libffarawmodules.so)

void Fun4All_Stream_Combiner(int nEvents = 100,
			     int runnumber = 30117,
			     const string &type = "beam",
			     const string &outdir = "/sphenix/lustre01/sphnxpro/commissioning/slurp/tpccosmics/",
                             const string &input_tpcfile00 = "tpc00.list",
                             const string &input_tpcfile01 = "tpc01.list",
                             const string &input_tpcfile02 = "tpc02.list",
                             const string &input_tpcfile03 = "tpc03.list",
                             const string &input_tpcfile04 = "tpc04.list",
                             const string &input_tpcfile05 = "tpc05.list",
                             const string &input_tpcfile06 = "tpc06.list",
                             const string &input_tpcfile07 = "tpc07.list",
                             const string &input_tpcfile08 = "tpc08.list",
                             const string &input_tpcfile09 = "tpc09.list",
                             const string &input_tpcfile10 = "tpc10.list",
                             const string &input_tpcfile11 = "tpc11.list",
                             const string &input_tpcfile12 = "tpc12.list",
                             const string &input_tpcfile13 = "tpc13.list",
                             const string &input_tpcfile14 = "tpc14.list",
                             const string &input_tpcfile15 = "tpc15.list",
                             const string &input_tpcfile16 = "tpc16.list",
                             const string &input_tpcfile17 = "tpc17.list",
                             const string &input_tpcfile18 = "tpc18.list",
                             const string &input_tpcfile19 = "tpc19.list",
                             const string &input_tpcfile20 = "tpc20.list",
                             const string &input_tpcfile21 = "tpc21.list",
                             const string &input_tpcfile22 = "tpc22.list",
                             const string &input_tpcfile23 = "tpc23.list"
)
{
  vector<string> tpc_infile;
  tpc_infile.push_back(input_tpcfile00);
  tpc_infile.push_back(input_tpcfile01);
  tpc_infile.push_back(input_tpcfile02);
  tpc_infile.push_back(input_tpcfile03);
  tpc_infile.push_back(input_tpcfile04);
  tpc_infile.push_back(input_tpcfile05);
  tpc_infile.push_back(input_tpcfile06);
  tpc_infile.push_back(input_tpcfile07);
  tpc_infile.push_back(input_tpcfile08);
  tpc_infile.push_back(input_tpcfile09);
  tpc_infile.push_back(input_tpcfile10);
  tpc_infile.push_back(input_tpcfile11);
  tpc_infile.push_back(input_tpcfile12);
  tpc_infile.push_back(input_tpcfile13);
  tpc_infile.push_back(input_tpcfile14);
  tpc_infile.push_back(input_tpcfile15);
  tpc_infile.push_back(input_tpcfile16);
  tpc_infile.push_back(input_tpcfile17);
  tpc_infile.push_back(input_tpcfile18);
  tpc_infile.push_back(input_tpcfile19);
  tpc_infile.push_back(input_tpcfile20);
  tpc_infile.push_back(input_tpcfile21);
  tpc_infile.push_back(input_tpcfile22);
  tpc_infile.push_back(input_tpcfile23);


  Fun4AllServer *se = Fun4AllServer::instance();
  se->Verbosity(1);
  recoConsts *rc = recoConsts::instance();
  // rc->set_IntFlag("RUNNUMBER",20445);
  Fun4AllStreamingInputManager *in = new Fun4AllStreamingInputManager("Comb");
  //  in->Verbosity(2);
  int i = 0;
  for (auto iter : tpc_infile)
  {
    SingleTpcPoolInput *tpc_sngl = new SingleTpcPoolInput("TPC_" + to_string(i));
    //    tpc_sngl->Verbosity(3);
    tpc_sngl->SetBcoRange(130);
    tpc_sngl->AddListFile(iter);
    in->registerStreamingInput(tpc_sngl, InputManagerType::TPC);
    i++;
  }

  se->registerInputManager(in);
//  StreamingCheck *scheck = new StreamingCheck();
//  scheck->SetTpcBcoRange(130);
  // se->registerSubsystem(scheck);
  // TpcCheck *tpccheck = new TpcCheck();
  // tpccheck->Verbosity(3);
  // tpccheck->SetBcoRange(130);
  // se->registerSubsystem(tpccheck);

  string outfilename = "./" + type + ".root";
  Fun4AllOutputManager *out = new Fun4AllDstOutputManager("out",outfilename);
  out->UseFileRule();
  out->SetNEvents(10);                       // number of events per output file
  out->SetClosingScript("stageout.sh");      // script to call on file close (not quite working yet...)
  out->SetClosingScriptArgs(outdir);  // additional beyond the name of the file
  se->registerOutputManager(out);

  if (nEvents < 0)
  {
    return;
  }
  se->run(nEvents);

  se->End();
  delete se;
  cout << "all done" << endl;
  gSystem->Exit(0);
}
