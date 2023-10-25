end_of_month=("Jan 31" "Feb 28" "Mar 31" "Apr 30" "May 31" "Jun 30" "Jul 31" "Aug 31" "Sep 30" "Oct 31" "Nov 30" "Dec 31")

if [[ ${end_of_month[@]} =~ `date '+%b %d'` ]]
then
  echo "last day of month"
  prefix="monthly"
else
  echo "daily"
  prefix="daily"
fi

if [ `date '+%d'` = "01" ]; 
then 
    prefix="monthly";
else 
    prefix="daily"; 
fi


 

 

 
 



 

 