import sys
import json
from yahooquery import Ticker


class Request:
    def __init__(self):
        if len(sys.argv) > 2:
            self.args = []
            self.method = sys.argv[1]
            x = range(2, len(sys.argv))
            for i in x:
                self.args.append(sys.argv[i])
            self.ticker = Ticker(self.args)
    def send(self):
            self.response = getattr(self.ticker, self.method)

request = Request()
request.send()
print(json.dumps(request.response))


# module_methods = ['company_officers', 'earning_history', 'earnings', 'earnings_trend', 'esg_scores',
#                   'financial_data', 'fund_bond_holdings', 'fund_bond_ratings', 'fund_equity_holdings', 
#                   'fund_holding_info', 'fund_ownership', 'fund_performance', 'fund_profile', 'fund_sector_weightings',
#                   'fund_top_holdings', 'grading_history', 'industry_trend', 'insider_holdings', 'insider_transactions', 
#                   'institution_ownership', 'key_stats', 'major_holders', 'page_views', 'price', 'quote_type',
#                   'recommendation_trend', 'sec_filings', 'share_purchase_activity', 'summary_detail', 'summary_profile',
#                   'all_modules', 'asset_profile', 'calendar_events']
# 
