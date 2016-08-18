#property strict
#include "Include/Error.mqh"

int OnInit()
   {
      Print("==========start unit test==========");
      Print("==========end unit test==========");
      ExpertRemove();
      return INIT_SUCCEEDED;
   }
void OnDeinit(const int reason)
   {
   }
