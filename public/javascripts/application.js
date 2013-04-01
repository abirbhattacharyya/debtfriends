// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

    //function new_change_days(month, year, day, day_name)

   
    function change_days(month, year)
    {
        month_val = parseInt(month)
        year_val = parseInt(year)
        if((month_val == 1) || (month_val == 3) || (month_val == 5) || (month_val == 7) || (month_val == 8) || (month_val == 10) || (month_val == 12))
        {
            document.getElementById("days31").style.display = "inline";
            document.getElementById("days30").style.display = "none";
            document.getElementById("days29").style.display = "none";
            document.getElementById("days28").style.display = "none";
            if($("day30").value != 1)
                $("day31").value = $("day30").value;
            else if($("day29").value != 1)
                $("day31").value = $("day29").value;
            else if($("day28").value != 1)
                $("day31").value = $("day28").value;
        }
        else if((month_val == 4) || (month_val == 6) || (month_val == 9) || (month_val == 11))
        {
            document.getElementById("days31").style.display = "none";
            document.getElementById("days30").style.display = "inline";
            document.getElementById("days29").style.display = "none";
            document.getElementById("days28").style.display = "none";
            if($("day31").value != 1)
                $("day30").value = $("day31").value;
            else if($("day29").value != 1)
                $("day30").value = $("day29").value;
            else if($("day28").value != 1)
                $("day30").value = $("day28").value;
        }
        else
        {
            if(checkleapyear(year))
            {
                document.getElementById("days31").style.display = "none";
                document.getElementById("days30").style.display = "none";
                document.getElementById("days29").style.display = "inline";
                document.getElementById("days28").style.display = "none";
                if($("day31").value != 1)
                    $("day29").value = $("day31").value;
                else if($("day30").value != 1)
                    $("day29").value = $("day30").value;
                else if($("day28").value != 1)
                    $("day29").value = $("day28").value;
            }
            else
            {
                document.getElementById("days31").style.display = "none";
                document.getElementById("days30").style.display = "none";
                document.getElementById("days29").style.display = "none";
                document.getElementById("days28").style.display = "inline";
                if($("day31").value != 1)
                    $("day28").value = $("day31").value;
                else if($("day30").value != 1)
                    $("day28").value = $("day30").value;
                else if($("day29").value != 1)
                    $("day28").value = $("day29").value;
            }
        }
    }

    function checkleapyear(year)
    {
       datea = parseInt(year);
        if(datea%4 == 0)
        {
            if(datea%100 != 0)
                return true;
            else
            {
                if(datea%400 == 0)
                    return true;
                else
                    return false;
            }
        }
        return false;
    }

function PopupCenter(pageURL, title,w,h) 
{
var left = (screen.width/2)-(w/2);
var top = (screen.height/2)-(h/2);
return window.open (pageURL, title, 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=no, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left);
}
