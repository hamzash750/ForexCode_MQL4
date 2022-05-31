//+------------------------------------------------------------------+
//|                                                CandelStratgy.mq4 |
//|                                                     Hamza Shafiq |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hamza Shafiq"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
double CurrentOpenBodyPrice;
double CurrentCloseBodyPrice;
double CurrentHighWickPrice;
double CurrentLowWickPrice;
double LastOpenBodyPrice;
double LastCloseBodyPrice;
double LastHighWickPrice;
double LastLowWickPrice;
double LastTime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   FindFifteenCandel(Symbol());
// Print("CurrentOpenBodyPrice= "+CurrentOpenBodyPrice);
// Print("CurrentCloseBodyPrice= "+CurrentCloseBodyPrice);
// Print("CurrentHighWickPrice= "+CurrentHighWickPrice);
//  Print("CurrentLowWickPrice= "+CurrentLowWickPrice);
   Print("LastOpenBodyPrice= "+LastOpenBodyPrice);
   Print("LastCloseBodyPrice= "+LastCloseBodyPrice);
   Print("LastHighWickPrice= "+LastHighWickPrice);
   Print("LastLowWickPrice= "+LastLowWickPrice);
   Print("LastTime= "+LastTime);
   Print("TimeLocal= "+TimeLocal());
   Print("TimeCurrent= "+TimeCurrent());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindFifteenCandel(string pair)
  {

   CurrentOpenBodyPrice=  iOpen(pair,PERIOD_H1,0);
   CurrentCloseBodyPrice=iClose(pair,PERIOD_H1,0);
   CurrentHighWickPrice=iHigh(pair,PERIOD_H1,0);
   CurrentLowWickPrice=iLow(pair,PERIOD_H1,0);
   LastOpenBodyPrice= iOpen(pair,PERIOD_H1,18);
   LastCloseBodyPrice=iClose(pair,PERIOD_H1,18);
   LastHighWickPrice=iHigh(pair,PERIOD_H1,18);
   LastLowWickPrice=iLow(pair,PERIOD_H1,18);
   LastTime =iTime(pair,PERIOD_H1,18);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
