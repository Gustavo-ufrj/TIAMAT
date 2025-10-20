<!--#include virtual="/system.asp"-->
<!--#include virtual="/checkstep.asp"-->
<!--#include file="INC_ROADMAP.inc"-->

<%
saveCurrentURL
Dim rs

tiamat.addCSS("timeline.css")
tiamat.addJS("hammer.min.js")
tiamat.addCSS("yearpicker.css")
tiamat.addJS("yearpicker.js")

render.renderTitle()
%>

<div class="p-3">

<nav>
  <div class="nav nav-tabs" id="nav-tab" role="tablist">
    <button class="nav-link text-dark active" id="nav-events-tab" data-bs-toggle="tab" data-bs-target="#nav-events" type="button" role="tab" aria-controls="nav-events" aria-selected="true">Events</button>
    <button class="nav-link text-dark " id="nav-roadmap-tab" data-bs-toggle="tab" data-bs-target="#nav-roadmap" type="button" role="tab" aria-controls="nav-roadmap" aria-selected="false">Roadmap</button>
  </div>
</nav>

<div class="tab-content" id="nav-tabContent">
  <div class="tab-pane fade show active" id="nav-events" role="tabpanel" aria-labelledby="nav-events">
 
<%
call getRecordSet(SQL_CONSULTA_ROADMAP_EVENTS_SORTING(request.querystring("stepID"), "date ASC"), rs)

if rs.eof then
    response.write "<div class='py-3'><div class='alert alert-danger'> No Event was found.</div></div>"
else
%>
<table class="table table-striped table-hover">
  <thead class="table-dark">
    <tr>
        <td class="text-center" style="min-width:80px">Year</td>
        <td class="w-100" >Event</td>
        <td class="text-center" style="min-width:80px">Actions</td>
    </tr>
  </thead>
  <tbody>
<%
    while not rs.eof
    %>
    <tr>
        <td class="text-center" >														
        <%=cstr(year(rs("date")))%>						
        </td>												
        <td>														
        <%=rs("event")%>						
        </td>												
        <td class="text-center" >														
            <a href="#" title="Edit" data-bs-toggle="modal" data-bs-target="#manageEvents" data-title="Edit Event" data-url="eventActions.asp?action=update&roadmapID=<%=Request.QueryString("stepID")%>" data-event-id="<%=cstr(rs("eventID"))%>" data-event="<%=rs("event")%>" data-year="<%=cstr(year(rs("date")))%>"><img src="/img/edit.png"  height=20 width=auto></a>
            <a href="eventActions.asp?action=delete&roadmapID=<%=Request.QueryString("stepID")%>&eventID=<%=cstr(rs("eventID"))%>" title="Delete" onclick="if (!confirm('Are you sure?')) { return false; }"><img src="/img/delete.png"  height=20 width=auto></a>
        </td>												
    </tr>
    <%
    rs.movenext
    wend
    %>										
  </tbody>
</table>
<%
end if
%>										
 
  </div>
  
  <div class="tab-pane fade" id="nav-roadmap" role="tabpanel" aria-labelledby="nav-roadmap">
    <section class="timeline">
      <ol>
      <%
        call getRecordSet(SQL_CONSULTA_ROADMAP_EVENTS_SORTING(request.querystring("stepID"), "date ASC"), rs)
        
        while not rs.eof 																							
        %>
        <li>
          <div>
            <time><%=cstr(year(rs("date")))%></time>
            <%=cstr(rs("event"))%>
          </div>
        </li>
        <%
        rs.MoveNext
        wend
      %>
        <li></li>
      </ol>
       
      <div class="arrows">
        <button class="arrow arrow__prev timeline disabled" disabled="" style="z-index:3">
          <img src="arrow_prev.svg" alt="previous events">
        </button>
        <button class="arrow arrow__next timeline" style="z-index:3">
          <img src="arrow_next.svg" alt="next events">
        </button>
      </div>
    </section>												
  </div>
</div>
 
<div class="p-3">
</div>

<nav class="navbar fixed-bottom navbar-light bg-light">
    <div class="container-fluid justify-content-center p-0">
        <button class="btn btn-sm btn-secondary m-1" type="button" data-bs-toggle="modal" data-bs-target="#manageEvents" data-title="Add Event" data-url="eventActions.asp?action=new&roadmapID=<%=Request.QueryString("stepID")%>" data-event-id="" data-event="" data-year=""> 
            <i class="bi bi-plus-square text-light"></i> Add Event
        </button>
        
        <!-- NOVO: Botão View DC para ver dados Dublin Core -->
        <button class="btn btn-sm btn-info m-1" type="button" onclick="verDublinCore()">
            <i class="bi bi-eye text-light"></i> View DC
        </button>
        
        <button class="btn btn-sm btn-danger m-1" onclick="window.location.href='/stepsupportInformation.asp?stepID=<%=request.queryString("stepID")%>';"><i class="bi bi-journal-plus text-light"></i> Supporting Information</button>
        <button class="btn btn-sm btn-danger m-1" onclick="if(confirm('This action cannot be undone. Are you sure to end this FTA method now?'))window.location.href='/workflowActions.asp?action=end&stepID=<%=request.queryString("stepID")%>'"><i class="bi bi-check-lg text-light"></i> Finish</button>
    </div>
</nav>		
 
<div>

 <!-- Manage Event -->
<div class="modal fade" id="manageEvents" tabindex="-1" aria-labelledby="eventModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
    <form method="post" action="" autocomplete="off"  id ="formManageEvents" class="requires-validation m-0" novalidate>
      <div class="modal-header">
        <h5 class="modal-title" id="eventModalLabel">xx</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
       <div class="mb-3">
        <label for="date" class="form-label">Year</label>
        <input type="text" class="form-control" id="date" name="date" size="4" required> 
        <div class="invalid-feedback">Year cannot be blank!</div>
      </div>
      
      <div class=" mb-3">
        <label for="event" class="form-label">Event</label>
        <textarea class="form-control" id="event" rows="3" name="event" required></textarea>
        <div class="invalid-feedback">Event cannot be blank!</div>
      </div>
          
      </div>
      <div class="modal-footer">
        <input type="hidden" name="eventID">
        <button type="button" class="btn btn-sm btn-secondary m-1 text-center" data-bs-dismiss="modal">Close</button>
        <button type="submit" class="btn btn-sm btn-danger m-1 text-center" ><i class="bi bi-save text-light"></i> Save</button>
      </div> 
    </form>
    </div>
  </div>
</div>		
    
<script>
// Função para abrir popup com dados Dublin Core específico do Roadmap
function verDublinCore() {
    var popup = window.open('dcDataRoadmap.asp?stepID=<%=Request.QueryString("stepID")%>', 
                           'DublinCoreData', 
                           'width=1000,height=800,scrollbars=yes,resizable=yes');
    popup.focus();
}

$('#manageEvents').on('show.bs.modal', function(e) {
    var title = $(e.relatedTarget).data('title');
    var year = $(e.relatedTarget).data('year');
    var event = $(e.relatedTarget).data('event');
    var url = $(e.relatedTarget).data('url');
    var eventID = $(e.relatedTarget).data('eventId');
    
    $(e.currentTarget).find('#formManageEvents').attr('action', url);
    $(e.currentTarget).find('#eventModalLabel').html(title);
    $(e.currentTarget).find('input[name="date"]').val(year);
    $(e.currentTarget).find('textarea[name="event"]').val(event);
    $(e.currentTarget).find('input[name="eventID"]').val(eventID);
});
</script>
    
<script>
$('#nav-tab').on("shown.bs.tab",function(e){
    localStorage.setItem("roadmap-idtab", e.target.id);
});

$( document ).ready(function() {
   var id_tab = localStorage.getItem("roadmap-idtab"); 
   if (id_tab!="") {
       var triggerEl = document.querySelector("#"+id_tab)
       triggerEl.click();
   }
});
</script>

<script>
(function() {
    // VARIABLES
    const timeline = document.querySelector(".timeline ol"),
        elH = document.querySelectorAll(".timeline li > div"),
        arrows = document.querySelectorAll(".timeline .arrows .arrow"),
        arrowPrev = document.querySelector(".timeline .arrows .arrow__prev"),
        arrowNext = document.querySelector(".timeline .arrows .arrow__next"),
        firstItem = document.querySelector(".timeline li:first-child"),
        lastItem = document.querySelector(".timeline li:last-child"),
        xScrolling = 500,
        disabledClass = "disabled";
        positionScroll = 0;
        maxScroll = 1;
        minScroll = 0;

    // START
    window.addEventListener("load", init);

    function init() {
        setEqualHeights(elH);
        animateTl(xScrolling, arrows, timeline);
        setSwipeFn(timeline, arrowPrev, arrowNext);
        setKeyboardFn(arrowPrev, arrowNext);
        defineMaxScroll();
    }

    function defineMaxScroll(){
        maxScroll = Math.ceil((elH.length-1)/4)+1;
        return;
    }

    // SET EQUAL HEIGHTS
    function setEqualHeights(el) {
        let counter = 0;
        for (let i = 0; i < el.length; i++) {
            const singleHeight = el[i].offsetHeight;
            if (counter < singleHeight) {
                counter = singleHeight;
            }
        }
        
        if (counter == 0) counter = 150;
        
        for (let i = 0; i < el.length; i++) {
            el[i].style.height = `${counter}px`;
        }
    }

    // SET STATE OF PREV/NEXT ARROWS
    function setBtnDisabled(el, state) {
        if (state) {
            el.classList.add(disabledClass);
        } else {
            if (el.classList.contains(disabledClass)) {
                el.classList.remove(disabledClass);
            }
            el.disabled = false;
        }
    }

    // ANIMATE TIMELINE
    function animateTl(scrolling, el, tl) {
        let counter = 0;
        for (let i = 0; i < el.length; i++) {
            el[i].addEventListener("click", function(e) {
                e.stopPropagation();
                if (!arrowPrev.disabled) {
                    arrowPrev.disabled = true;
                }
                if (!arrowNext.disabled) {
                    arrowNext.disabled = true;
                }
                const sign = (this.classList.contains("arrow__prev")) ? "" : "-";
                if (counter === 0) {
                    tl.style.transform = `translateX(-${scrolling}px)`;
                } else {
                    const tlStyle = getComputedStyle(tl);
                    const tlTransform = tlStyle.getPropertyValue("-webkit-transform") || tlStyle.getPropertyValue("transform");
                    const values = parseInt(tlTransform.split(",")[4]) + parseInt(`${sign}${scrolling}`);
                    tl.style.transform = `translateX(${values}px)`;
                }
                positionScroll = (this.classList.contains("arrow__prev")) ? positionScroll - 1 : positionScroll + 1;
                setTimeout(() => {
                   setBtnDisabled(arrowPrev, (positionScroll === minScroll));
                   setBtnDisabled(arrowNext, (positionScroll === maxScroll));
                }, 1100);

                counter++;
            });
        }
    }

    // ADD SWIPE SUPPORT FOR TOUCH DEVICES
    function setSwipeFn(tl, prev, next) {
        const hammer = new Hammer(tl);
        hammer.on("swipeleft", () => next.click());
        hammer.on("swiperight", () => prev.click());
    }

    // ADD BASIC KEYBOARD FUNCTIONALITY
    function setKeyboardFn(prev, next) {
        document.addEventListener("keydown", (e) => {
            if ((e.which === 37) || (e.which === 39)) {
                const timelineOfTop = timeline.offsetTop;
                const y = window.pageYOffset;
                if (timelineOfTop !== y) {
                    window.scrollTo(0, timelineOfTop);
                }
                if (e.which === 37) {
                    prev.click();
                } else if (e.which === 39) {
                    next.click();
                }
            }
        });
    }
})();
</script>

<script>
$("#date").yearpicker();

// Fetch all the forms we want to apply custom Bootstrap validation styles to
var forms = document.querySelectorAll('.requires-validation');

// Loop over them and prevent submission
Array.prototype.slice.call(forms)
    .forEach(function (form) {
        form.addEventListener('submit', function (event) {
            if (!form.checkValidity()) {
                event.preventDefault()
                event.stopPropagation()
            }
            form.classList.add('was-validated')
        }, false)
    });
</script>

<%
render.renderFooter()
%>