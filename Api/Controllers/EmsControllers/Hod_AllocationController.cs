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
    public class Hod_AllocationController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveHod_Allocation(SaveHod_AllocationDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                Hod_AllocationDAL dal = new Hod_AllocationDAL();
                var dynobj = new { result = dal.SaveHod_Allocation(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage ModifyHod_Allocation(ModifyHod_AllocationDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                Hod_AllocationDAL dal = new Hod_AllocationDAL();
                var dynobj = new { result = dal.ModifyHod_Allocation(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RemoveHod_Allocation(RemoveHod_AllocationDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                Hod_AllocationDAL dal = new Hod_AllocationDAL();
                var dynobj = new { result = dal.RemoveHod_Allocation(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectHod_Allocation()
        {
            HttpResponseMessage message;
            try
            {
                Hod_AllocationDAL dal = new Hod_AllocationDAL();
                var dynobj = new { result = dal.SelectHod_Allocation() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage Employee()
        {
            HttpResponseMessage message;
            try
            {
                Hod_AllocationDAL dal = new Hod_AllocationDAL();
                var dynobj = new { result = dal.Employee() };
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
