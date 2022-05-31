//+------------------------------------------------------------------+
//|                                                     EAMoving.mq4 |
//|                                                     Hamza Shafiq |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hamza Shafiq"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
input string CurrencyPair="XAUUSDm";
extern double    Risk          = 10.0;//Percent Risk

int TotalGBuyOrder=0;
int TotalGSellOrder=0;
int TotalGPBuyOrder=0;
int TotalGPSellOrder=0;
int TotalOrderPair=0;
double TotalProfit=0;
input double TotalOrder     = 30;
enum ENUM_CUSTOMTIMEFRAMES
  {
   CURRENT=PERIOD_CURRENT,             //CURRENT PERIOD
   M1=PERIOD_M1,                       //M1
   M5=PERIOD_M5,                       //M5
   M15=PERIOD_M15,                     //M15
   M30=PERIOD_M30,                     //M30
   H1=PERIOD_H1,                       //H1
   H4=PERIOD_H4,                       //H4
   D1=PERIOD_D1,                       //D1
   W1=PERIOD_W1,                       //W1
   MN1=PERIOD_MN1,                     //MN1
  };
extern ENUM_CUSTOMTIMEFRAMES SRTimeframe=CURRENT;
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
//---
   double AskPrice = MarketInfo(CurrencyPair, MODE_ASK);
   double MR=iMA(Symbol(),0,200,0,MODE_SMA,PRICE_CLOSE,0);
   if(AskPrice<MR)
     {
      if(candelCloseBodyPrice(0)<candelCloseBodyPrice(1))
        {
         sendSellOrder();
        }

     }
   else
     {
      if(candelOpenBodyPrice(0)>candelOpenBodyPrice(1))
        {
         sendBuyOrder();
        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckOpenOrders()
  {
   int totalSell=0;
   int totalBuy=0;
   int totalPSell=0;
   int totalPBuy=0;
   TotalProfit=0;
   selldiffernce=0;
   buydiffernce=0;
   buyCount=0;
   sellCount=0;

// We need to scan all the open and pending orders to see if there are any.
// OrdersTotal returns the total number of market and pending orders.
// What we do is scan all orders and check if they are of the same symbol as the one where the EA is running.
   for(int i = 0 ; i < OrdersTotal() ; i++)
     {
      // We select the order of index i selecting by position and from the pool of market/pending trades.
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==CurrencyPair)
        {
         // If the pair of the order is equal to the pair where the EA is running.
         if(OrderType()==OP_BUY)
           {
            totalBuy=totalBuy+1;
            TotalProfit=TotalProfit+OrderProfit();
           }
         if(OrderType()==OP_SELL)
           {
            TotalProfit=TotalProfit+OrderProfit();
            totalSell=totalSell+1;

           }
         if(OrderType()==OP_BUYSTOP)
           {
            totalPBuy=totalPBuy+1;


            ModifyOrderForBuyStop(OrderTicket());


           }
         if(OrderType()==OP_SELLSTOP)
           {
            totalPSell=totalPSell+1;

            ModifyOrderForSellStop(OrderTicket());

           }
        }

     }

   TotalGBuyOrder=totalBuy;
   TotalGSellOrder=totalSell;
   TotalGPBuyOrder=totalPBuy;
   TotalGPSellOrder=totalPSell;
   ShowOrderInBlock();
// If the loop finishes it mean there were no open orders for that pair.
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double candelOpenBodyPrice(int candel)
  {
   return iOpen(CurrencyPair,SRTimeframe,candel);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double candelCloseBodyPrice(int candel)
  {
   return iClose(CurrencyPair,SRTimeframe,candel);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double candelWickHigh(int candel)
  {
   return iHigh(CurrencyPair,SRTimeframe,candel);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double candelWickLow(int candel)
  {
   return iLow(CurrencyPair,SRTimeframe,candel);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sendBuyOrder()
  {
   bool res;
   double BidPrice = MarketInfo(CurrencyPair, MODE_BID);
   double AskPrice = MarketInfo(CurrencyPair, MODE_ASK);

   res=OrderSend(CurrencyPair,OP_BUY,getLot(),AskPrice,0,NULL,NULL);
   if(!res)
      Print("Error in sendBuyOrder. Error code=",GetLastError());
   else
      Print("Order sendBuyOrder successfully.");

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sendSellOrder()
  {
   bool res;
   double BidPrice = MarketInfo(CurrencyPair, MODE_BID);
   double AskPrice = MarketInfo(CurrencyPair, MODE_ASK);
   res=OrderSend(CurrencyPair,OP_SELL,getLot(),AskPrice,0,NULL,NULL);
   if(!res)
      Print("Error in sendSellOrder. Error code=",GetLastError());
   else
      Print("Order sendSellOrder successfully.");
  }
float selldiffernce=0;
int sellCount=0;
void ModifyOrderForSellStop(int currentOrderTicket)
  {
   float AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
   if(TotalGBuyOrder>TotalGSellOrder)
     {
      Print("Order modified For Sell.");
      if(sellCount<(TotalGBuyOrder-TotalGSellOrder))
        {
         Print("Order modified Sell Condition.");
         selldiffernce=0;
         sellCount=sellCount+1;
        }
      selldiffernce=selldiffernce+PointDiffernce;
      if(AskPrice-selldiffernce>OrderOpenPrice())
        {
         bool res;
         res=  OrderModify(currentOrderTicket,(AskPrice-selldiffernce),NULL,NULL,0,Red);
         if(!res)
            Print("Error in OrderModify. Error code=",GetLastError());
         else
            Print("Order modified successfully."+OrderOpenPrice());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+d

float buydiffernce=0;
int buyCount=0;
void ModifyOrderForBuyStop(int currentOrderTicket)
  {
   float AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
   if(TotalGBuyOrder<TotalGSellOrder)
     {
      Print("Order modified For Buy.");
      if(buyCount<(TotalGSellOrder-TotalGBuyOrder))
        {
         Print("Order modified Buy Condition.");
         buydiffernce=0;
         buyCount=buyCount+1;
        }
      buydiffernce=buydiffernce+PointDiffernce;
      if(AskPrice+buydiffernce<OrderOpenPrice())
        {
         bool res;
         res= OrderModify(currentOrderTicket,(AskPrice+buydiffernce),NULL,NULL,0,Blue);
         if(!res)
            Print("Error in OrderModify. Error code=",GetLastError());
         else
            Print("Order modified successfully."+OrderOpenPrice());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLot()
  {
// return 0.01;
   return MathMin(MathMax((MathRound((AccountFreeMargin()*Risk/100000)/MarketInfo(CurrencyPair,MODE_LOTSTEP))*MarketInfo(CurrencyPair,MODE_LOTSTEP)),MarketInfo(CurrencyPair,MODE_MINLOT)),MarketInfo(CurrencyPair,MODE_MAXLOT));
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
