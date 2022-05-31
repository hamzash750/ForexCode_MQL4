//+------------------------------------------------------------------+
//|                                                DynamicDanger.mq4 |
//|                                                     Hamza Shafiq |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hamza Shafiq"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICNUM  20131111

input double Lots          = 0.01;
input double TakeProfit       = 0;
input double StopLoss         = 0;
input double TralingTakeProfit         = 0;
input double TralingStopLoss         = 0;


string GoldPair="XAUUSDm";
string EuroPair="EURUSDm";
string JPYPair="USDJPYm";
string GBPPair="GBPUSDm";
string US30Pair="US30m";
string CADPair="USDCADm";
string NASPair="USTECm";

double CurrentOpenBodyPrice;
double CurrentCloseBodyPrice;
double CurrentHighWickPrice;
double CurrentLowWickPrice;
double LastOpenBodyPrice;
double LastCloseBodyPrice;
double LastHighWickPrice;
double LastLowWickPrice;
int  ticket, total;
//+------------------------------------------------------------------+
//| Expert initialization function

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   int GoldOrder=CalculateCurrentOrders(GoldPair);
   int US30Order=CalculateCurrentOrders(US30Pair);
   int EurOrder=CalculateCurrentOrders(EuroPair);
   int JPYOrder=CalculateCurrentOrders(JPYPair);
   int GBPOrder=CalculateCurrentOrders(GBPPair);
   int CADOrder=CalculateCurrentOrders(CADPair);
   int NASOrder=CalculateCurrentOrders(NASPair);
   if(OrdersTotal()<11)
     {
      if(GoldOrder<1&&Symbol()==GoldPair)
        {
         openOrder(GoldPair);
        }

      if(US30Order<1&&Symbol()==US30Pair)
        {
         openOrder(US30Pair);
        }

      if(EurOrder<1&&Symbol()==EuroPair)
        {

         openOrder(EuroPair);
        }
      if(JPYOrder<1&&Symbol()==JPYPair)
        {

         openOrder(JPYPair);
        }
      if(GBPOrder<1&&Symbol()==GBPPair)
        {

         openOrder(GBPPair);
        }
      if(CADOrder<1&&Symbol()==CADPair)
        {

         openOrder(CADPair);
        }
      if(NASOrder<1&&Symbol()==NASPair)
        {

         openOrder(NASPair);
        }
     }
   calculatedCurrentStopLossProfit();
   CloseTakeProfit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void findCurrentLastCandelPrices(string pair)
  {
   CurrentOpenBodyPrice=  iOpen(pair,PERIOD_M1,0);
   CurrentCloseBodyPrice=iClose(pair,PERIOD_M1,0);
   CurrentHighWickPrice=iHigh(pair,PERIOD_M1,0);
   CurrentLowWickPrice=iLow(pair,PERIOD_M1,0);
   LastOpenBodyPrice= iOpen(pair,PERIOD_M1,2);
   LastCloseBodyPrice=iClose(pair,PERIOD_M1,2);
   LastHighWickPrice=iHigh(pair,PERIOD_M1,2);
   LastLowWickPrice=iLow(pair,PERIOD_M1,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openOrder(string pair)
  {
   findCurrentLastCandelPrices(pair);
   double BidPrice = MarketInfo(pair, MODE_BID);
   double AskPrice = MarketInfo(pair, MODE_ASK);
   if(AskPrice>LastHighWickPrice)
     {
      openBuyOrder(pair,AskPrice,BidPrice);
     }
   else
      if(AskPrice<LastLowWickPrice)
        {
         openSellOrder(pair,AskPrice,BidPrice);
        }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openBuyOrder(string pair,double AskPrice,double BidPrice)
  {
   Print(" Buy Condition");
   ticket = OrderSend(pair,OP_BUY, Lots,AskPrice,3,initialStopLoss("Buy"),initialTakeProfit("Buy",AskPrice,BidPrice),"Follow Trend",MAGICNUM,0,Blue);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openSellOrder(string pair,double AskPrice,double BidPrice)
  {
   Print(" Sell Condition");
   ticket = OrderSend(pair,OP_SELL, Lots,AskPrice,3,initialStopLoss("Sell"),initialTakeProfit("Sell",AskPrice,BidPrice),"Follow Trend",MAGICNUM,0,Red);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double initialStopLoss(string orderType)
  {
   if(orderType=="Buy")
     {
      return LastLowWickPrice;
     }
   else
     {
      return LastHighWickPrice;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double initialTakeProfit(string orderType,double AskPrice,double BidPrice)
  {
   if(orderType=="Buy")
     {
      return (AskPrice+TakeProfit);
     }
   else
     {
      return (BidPrice-TakeProfit);
     }
  }
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICNUM)
        {
         if(OrderType()==OP_BUY)
            buys++;
         if(OrderType()==OP_SELL)
            sells++;
        }
     }
//--- return orders volume
   if(buys>0)
      return(buys);
   else
      return(-sells);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseTakeProfit()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
      if(OrderProfit()>0.30){
      OrderClose(OrderTicket(),0.01,AskPrice,3,Red);
      }
      
     }


  }
//+------------------------------------------------------------------+
void calculatedCurrentStopLossProfit()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == Symbol())
        {
         findCurrentLastCandelPrices(OrderSymbol());
         double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
         double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
           {
            bool res;
            if(OrderType()==OP_BUY)
              {
               double stopLoss;
               double takeProfit;
               if(AskPrice>OrderOpenPrice())
                 {
                  if(OrderProfit()<1)
                    {
                     stopLoss=(OrderStopLoss()+TralingStopLoss);
                    }
                  else
                    {
                     stopLoss=(AskPrice-TralingStopLoss);
                    }
                  takeProfit=(AskPrice+TralingTakeProfit);
                 }
               else
                 {
                  stopLoss=(OrderOpenPrice()-StopLoss);
                  takeProfit=(OrderOpenPrice()+TakeProfit);
                 }
               res=  OrderModify(OrderTicket(),OrderOpenPrice(),LastLowWickPrice,takeProfit,0,Blue);
              }
            else
               if(OrderType()==OP_SELL)
                 {
                  double stopLoss;
                  double takeProfit;
                  if(AskPrice<OrderOpenPrice())
                    {
                     if(OrderProfit()>1)
                       {
                        stopLoss=(OrderStopLoss()-TralingStopLoss);
                       }
                     else
                       {
                        stopLoss=(AskPrice+TralingStopLoss);
                       }
                     takeProfit=(AskPrice-TralingTakeProfit);
                    }
                  else
                    {
                     stopLoss=(OrderOpenPrice()+StopLoss);
                     takeProfit=(OrderOpenPrice()-TakeProfit);
                    }

                  res=   OrderModify(OrderTicket(),OrderOpenPrice(),LastHighWickPrice,takeProfit,0,Green);

                 }
            if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            else
               Print("Order modified successfully.");
           }
        }


     }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

  }
//+------------------------------------------------------------------+
