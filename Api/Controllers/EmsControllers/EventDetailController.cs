using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using EmsApi.DAL;
using EmsApi.Models.EMS;

namespace EmsApi.Controllers.EmsControllers
{
    public class EventDetailController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveEventDetails(SaveEventDetailsDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                EventDetailsDAL dal = new EventDetailsDAL();
                var dynobj = new { result = dal.SaveEventDetails(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }

        //[HttpPost]
        //public HttpResponseMessage ModifyDepartment(ModifyDepartmentDTO obj)
        //{
        //    HttpResponseMessage message;
        //    try
        //    {
        //        DepartmentDAL dal = new DepartmentDAL();
        //        var dynobj =new { result = dal.ModifyDepartment(obj)};
        //        message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
        //    }
        //    catch (Exception ex)
        //    {
        //        message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
        //    }
        //    return message;
        //}
        [HttpPost]
        public HttpResponseMessage RemoveEventDetail(RemoveEventDetailsDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                EventDetailsDAL dal = new EventDetailsDAL();
                var dynobj = new { result = dal.RemoveEventDetail(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectEventDetail()
        {
            HttpResponseMessage message;
            try
            {
                EventDetailsDAL dal = new EventDetailsDAL();
                var dynobj = new { result = dal.SelectEvent() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
    }
}
