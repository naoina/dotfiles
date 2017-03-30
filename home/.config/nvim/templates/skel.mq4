#property copyright "Naoya Inada"
#property link      "https://kuune.org/"
#property version   "1.00"
#property strict
#include "Include/Error.mqh"
#include "Include/Trader.mqh"
#include "Include/Order.mqh"

class @FILE@ : public Trader
  {
public:
     @FILE@();
     ~@FILE@();
     Order* Buy();
     Order* Sell();
     bool CanCloseBuyOrder();
     bool CanCloseSellOrder();
private:
  };
@FILE@::@FILE@()
  {
  }
@FILE@::~@FILE@()
  {
  }
Order* @FILE@::Buy()
   {
      // TODO: implementation.
   }
Order* @FILE@::Sell()
   {
      // TODO: implementation.
   }
bool @FILE@::CanCloseBuyOrder()
   {
      // TODO: implementation.
   }
bool @FILE@::CanCloseSellOrder()
   {
      // TODO: implementation.
   }

static Trader *trader;

int OnInit()
   {
      if(!IsExpertEnabled())
         {
            Print("Auto Trading is disabled.");
            return INIT_FAILED;
         }
      trader = new @FILE@();
      return INIT_SUCCEEDED;
   }
void OnDeinit(const int reason)
   {
      delete trader;
   }
void OnTick()
   {
      Error* err;
      if((err = trader.Trade()) != NULL)
         {
            Print(err.GetMessage());
            delete err;
         }
   }
double OnTester()
   {
      const double profit_trades = TesterStatistics(STAT_PROFIT_TRADES);
      const double avg_profit = TesterStatistics(STAT_GROSS_PROFIT) / MathMax(profit_trades, 1);
      const double loss_trades = TesterStatistics(STAT_LOSS_TRADES);
      const double avg_loss = MathAbs(TesterStatistics(STAT_GROSS_LOSS) / MathMax(loss_trades, 1));
      const double adjusted_total_profit = (profit_trades - MathSqrt(profit_trades)) * avg_profit;
      const double adjusted_total_loss = (loss_trades + MathSqrt(loss_trades)) * avg_loss;
      const double adjusted_profit_factor = adjusted_total_profit / MathMax(adjusted_total_loss, 1);

      return adjusted_profit_factor;
   }
