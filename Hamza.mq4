//+------------------------------------------------------------------+
//|                                                   Double Sma.mq4 |
//|                                   Copyright 2017, Tom Whitbread. |
//|                                           http://www.gript.co.uk |
//+------------------------------------------------------------------+
#property copyright   "2017, Tom Whitbread."
#property link        "http://www.gript.co.uk"
#property description "Smoothed Moving Average sample expert advisor"

#define MAGICNUM  20131111

// Define our Parameters
input double Lots          = 0.10;
input int PeriodOne        = 40; // The period for the first SMA
input int PeriodTwo        = 100; // The period for the second SMA
input int TakeProfit       = 0; // The take profit level (0 disable)
input int StopLoss         = 0; // The default stop loss (0 disable)
//+------------------------------------------------------------------+
//| expert initialization functions                                  |
//+------------------------------------------------------------------+
int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Check for cross over of SMA                                      |
//+------------------------------------------------------------------+
int CheckForCross(double input1, double input2)
  {
   static int previous_direction = 0;
   static int current_direction  = 0;

// Up Direction = 1
   if(input1 > input2)
     {
      current_direction = 1;
     }

// Down Direction = 2
   if(input1 < input2)
     {
      current_direction = 2;
     }

// Detect a direction change
   if(current_direction != previous_direction)
     {
      previous_direction = current_direction;
      return (previous_direction);
     }
   else
     {
      return (0);
     }
  }

//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot = Lots;
// Calculate Lot size as a fifth of available free equity.
   lot = NormalizeDouble((AccountFreeMargin()/5)/1000.0,1);
   if(lot<0.1)
      lot=0.1; //Ensure the minimal amount is 0.1 lots
   return(0.01);
  }


//+------------------------------------------------------------------+
//+ Break Even                                                       |
//+------------------------------------------------------------------+
bool BreakEven(int MN)
  {
   int Ticket;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MN)
        {
         Ticket = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Green);
         if(Ticket < 0)
            Print("Error in Break Even : ", GetLastError());
         break;
        }
     }

   return(Ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void foundNCandelOpenClose(int candelNumber)
  {

   double Highest = High[0];
   double Lowest = Low[0];

// Scan the 30 candles and update the values of the highest and lowest.
   for(int i = 0; i <= candelNumber; i++)
     {
      if(High[i] > Highest)
         Highest = High[i];
      if(Low[i] < Lowest)
         Lowest = Low[i];
     }

// Print the result.
   Print("Highest price found is ", Highest, " - Lowest price found is ", Lowest);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   Print("Tick Function ");

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrders()
  {
// Update the exchange rates before closing the orders.
   RefreshRates();
// Log in the terminal the total of orders, current and past.
   Print(OrdersTotal());

// Start a loop to scan all the orders.
// The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.
   for(int i = (OrdersTotal() - 1); i >= 0; i--)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
        {
         Print("ERROR - Unable to select the order - ", GetLastError());
         break;
        }

      // Create the required variables.
      // Result variable - to check if the operation is successful or not.
      bool res = false;

      // Allowed Slippage - the difference between current price and close price.
      int Slippage = 0;

      // Bid and Ask prices for the instrument of the order.
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);

      // Closing the order using the correct price depending on the type of order.
      if(OrderType() == OP_BUY)
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      else
         if(OrderType() == OP_SELL)
           {
            res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
           }

      // If there was an error, log it.
      if(res == false)
         Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
     }
  }

//+------------------------------------------------------------------+
//+ Run the algorithm                                               |
//+------------------------------------------------------------------+
int start()
  {
   int cnt, ticket, total;
   double shortSma, longSma, ShortSL, ShortTP, LongSL, LongTP;
   double CurrentOpenBodyPrice=Open[0];
   double CurrentCloseBodyPrice=Close[0];
   double CurrentHighWickPrice=High[0];
   double CurrentLowWickPrice=Low[0];
   double LastOpenBodyPrice=Open[1];
   double LastCloseBodyPrice=Close[1];
   double LastHighWickPrice=High[1];
   double LastLowWickPrice=Low[1];
   double Spread = MarketInfo(Symbol(), MODE_SPREAD);
   Print(" Bid ="+Bid+"  Ask  ="+Ask+"  Point  ="+Point+"   Violet  ="+Violet+"  Spread = " + Spread);
   Print("  LastHighWickPrice  ="+LastHighWickPrice+"   LastLowWickPrice  ="+LastLowWickPrice);
   Print("  CurrentHighWickPrice  ="+CurrentHighWickPrice+"   CurrentLowWickPrice  ="+CurrentLowWickPrice);
   total = OrdersTotal();
   if(total<1)
     {
      if(CurrentHighWickPrice>LastHighWickPrice)
        {
         ticket = OrderSend(Symbol(),OP_BUY, 0.01,Ask,3,(Ask-15),(Ask+15),"Double SMA Crossover",MAGICNUM,0,Blue);
        }
      else
         if(CurrentLowWickPrice<LastLowWickPrice)
           {
            ticket = OrderSend(Symbol(),OP_SELL, 0.01,Ask,3,(Ask-15),(Ask+15),"Double SMA Crossover",MAGICNUM,0,Blue);
           }
     }
// Parameter Sanity checking
   if(PeriodTwo < PeriodOne)
     {
      Print("Please check settings, Period Two is lesser then the first period");
      return(0);
     }

   if(Bars < PeriodTwo)
     {
      Print("Please check settings, less then the second period bars available for the long SMA");
      return(0);
     }

// Calculate the SMAs from the iMA indicator in MODE_SMMA using the close price
   shortSma = iMA(NULL, 0, PeriodOne, 0, MODE_SMMA, PRICE_CLOSE, 0);
   longSma = iMA(NULL, 0, PeriodTwo, 0, MODE_SMMA, PRICE_CLOSE, 0);

// Check if there has been a cross on this tick from the two SMAs
   int isCrossed = CheckForCross(shortSma, longSma);

// Get the current total orders
   total = OrdersTotal();

// Calculate Stop Loss and Take profit
   if(StopLoss > 0)
     {
      ShortSL = Bid+(StopLoss*Point);
      LongSL = Ask-(StopLoss*Point);
     }
   if(TakeProfit > 0)
     {
      ShortTP = Bid-(TakeProfit*Point);
      LongTP = Ask+(TakeProfit*Point);
     }
// Manage open orders for exit criteria
   for(cnt = 0; cnt < total; cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() <= OP_SELL && OrderSymbol() == Symbol())
        {
         // Look for long positions
         if(OrderType() == OP_BUY)
           {
            // Check for Exit criteria on buy - change of direction
            if(isCrossed == 2)
              {
               OrderClose(OrderTicket(), OrderLots(), Bid, 3, Violet); // Close the position
               return(0);
              }
           }
         else //Look for short positions - inverse of prior conditions
           {
            // Check for Exit criteria on sell - change of direction
            if(isCrossed == 1)
              {
               OrderClose(OrderTicket(), OrderLots(), Ask, 3, Violet); // Close the position
               return(0);
              }
           }
         // If we are in a loss - Try to BreakEven
         //Print("Current Unrealized Profit on Order: ", OrderProfit());
         if(OrderProfit() < 0)
           {
            BreakEven(MAGICNUM);
           }
        }

     }

   return(0);
  }
//+------------------------------------------------------------------+
