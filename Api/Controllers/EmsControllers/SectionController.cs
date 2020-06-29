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
    public class SectionController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveSection(SaveSectionDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                SectionDAL dal = new SectionDAL();
                var dynobj = new { result = dal.SaveSection(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }

        [HttpPost]
        public HttpResponseMessage ModifySection(ModifySectionDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                SectionDAL dal = new SectionDAL();
                var dynobj = new { result = dal.ModifySection(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RemoveSection(RemoveSectionDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                SectionDAL dal = new SectionDAL();
                var dynobj = new { result = dal.RemoveSection(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectSection()
        {
            HttpResponseMessage message;
            try
            {
                SectionDAL dal = new SectionDAL();
                var dynobj = new { result = dal.SelectSection() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage ClassName()
        {
            HttpResponseMessage message;
            try
            {
                SectionDAL dal = new SectionDAL();
                var dynobj = new { result = dal.ClassName() };
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
