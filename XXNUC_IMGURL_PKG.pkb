create or replace PACKAGE BODY XXNUC_IMGURL_PKG IS

/* *************************************************************************************************************
   *                                             - Nucor -                                                    *
   **************************************************************************************************************
   * Application:   Sales, purchasing, AP                                                                       *
   * Program Name:  XXNUC_IMGURL_PKG                                                                            *
   * Title:         Image Attachment Program                                                                    *
   * Created by:    Ecovue Solutions                                                                            *
   * Creation Date: 06-Feb-2017                                                                                 *
   * Description:   Package to generate and attach WCI url to the transaction record in EBS                     *
   *                Program will also call a procedure to remove the EBS image                                  *
   *                                                                                                            *
   *                                                                                                            *
   * Change History:                                                                                            *
   *                                                                                                            *
   *============================================================================================================*
   * Date               | Name                     | Remarks                                                    *
   *============================================================================================================*
   * 06-Feb-2017      Soni Jonna             Initial Creation                                                   *
   ************************************************************************************************************ */
   
 /* *************************************************************************************************************
   *                                             - PROCEDURE add_ebs_attachment -                               *             
   ***********************************************************************************************************  */ 
PROCEDURE add_ebs_attachment(pk_value IN NUMBER,
                       doc_description IN VARCHAR2,
 					   URL IN VARCHAR2,
 					   entity_name IN VARCHAR2,
					   doc_category IN VARCHAR2,
					   doc_title IN VARCHAR2,
					   appuserid IN NUMBER,
					   respid IN NUMBER,
					   appid IN NUMBER ) IS
  l_rowid varchar2(1000);
  l_attached_document_id number;
  l_document_id number;
  l_media_id number;
  l_category_id number ; 
  l_pk1_value apps.fnd_attached_documents.pk1_value%TYPE := pk_value;
  l_description apps.fnd_documents_tl.description%TYPE   := doc_description;
  l_filename apps.fnd_documents_tl.file_name%TYPE := url;
  l_seq_num number;
   begin
  -- Setup applications session
  -- user_id, resp_id, resp_appl_id
  --fnd_global.apps_initialize(appUserID,respID,appID);
  axf_apps_init(appUserID,respID,appID);

  select APPS.FND_DOCUMENTS_S.nextval
  into   l_document_id
  from   dual;

  select APPS.FND_ATTACHED_DOCUMENTS_S.nextval
  into   l_attached_document_id
  from   dual;

  select nvl(max(seq_num),0) + 2
  into   l_seq_num
  from   APPS.fnd_attached_documents fad
  where  fad.pk1_value = l_pk1_value
  and    entity_name = entity_name;
  
  select category_id
  into   l_category_id
  from   APPS.fnd_document_categories_tl fdc
  WHERE  fdc.user_name = doc_category
    and  language = 'US';

  APPS.fnd_documents_pkg.insert_row
  ( X_ROWID                        => l_rowid
  , X_DOCUMENT_ID                  => l_document_id
  , X_CREATION_DATE                => sysdate
  , X_CREATED_BY                   => fnd_profile.value('USER_ID')
  , X_LAST_UPDATE_DATE             => sysdate
  , X_LAST_UPDATED_BY              => fnd_profile.value('USER_ID')
  , X_LAST_UPDATE_LOGIN            => fnd_profile.value('LOGIN_ID')
  , X_DATATYPE_ID                  => 5 -- Web Page
  , X_CATEGORY_ID                  => l_category_id
  , X_SECURITY_TYPE                => 2
  , X_PUBLISH_FLAG                 => 'Y'
  , X_USAGE_TYPE                   => 'O'
  , X_LANGUAGE                     => 'US'
  , X_DESCRIPTION                  => l_description
  , X_FILE_NAME                    => l_filename
  , x_url                          => url
  , X_title                        => doc_title
  , X_MEDIA_ID                     => l_media_id
  );

  APPS.fnd_attached_documents_pkg.insert_row
  ( X_ROWID                        => l_rowid
  , X_ATTACHED_DOCUMENT_ID         => l_attached_document_id
  , X_DOCUMENT_ID                  => l_document_id
  , X_CREATION_DATE                => sysdate
  , X_CREATED_BY                   => fnd_profile.value('USER_ID')
  , X_LAST_UPDATE_DATE             => sysdate
  , X_LAST_UPDATED_BY              => fnd_profile.value('USER_ID')
  , X_LAST_UPDATE_LOGIN            => fnd_profile.value('LOGIN_ID')
  , X_SEQ_NUM                      => l_seq_num
  , X_ENTITY_NAME                  => entity_name
  , X_COLUMN1                      => null
  , X_PK1_VALUE                    => l_pk1_value
  , X_PK2_VALUE                    => null
  , X_PK3_VALUE                    => null
  , X_PK4_VALUE                    => null
  , X_PK5_VALUE                    => null
  , X_AUTOMATICALLY_ADDED_FLAG     => 'N'
  , X_DATATYPE_ID                  => 5
  , X_CATEGORY_ID                  => l_category_id
  , X_SECURITY_TYPE                => 2
  , X_PUBLISH_FLAG                 => 'Y'
  , X_LANGUAGE                     => 'US'
  , X_DESCRIPTION                  => l_description
  , X_FILE_NAME                    => null
  , X_MEDIA_ID                     => l_media_id
  , X_title                        => doc_title
  , X_SECURITY_ID     => null
  , X_IMAGE_TYPE      => null
  , X_STORAGE_TYPE    => null
  , X_USAGE_TYPE      => null
  , X_DOC_ATTRIBUTE_CATEGORY  => null
  , X_DOC_ATTRIBUTE1    => null
  , X_DOC_ATTRIBUTE2    => null
  , X_DOC_ATTRIBUTE3    => null
  , X_DOC_ATTRIBUTE4    => null
  , X_DOC_ATTRIBUTE5    => null
  , X_DOC_ATTRIBUTE6    => null
  , X_DOC_ATTRIBUTE7    => null
  , X_DOC_ATTRIBUTE8    => null
  , X_DOC_ATTRIBUTE9    => null
  , X_DOC_ATTRIBUTE10   => null
  , X_DOC_ATTRIBUTE11   => null
  , X_DOC_ATTRIBUTE12   => null
  , X_DOC_ATTRIBUTE13   => null
  , X_DOC_ATTRIBUTE14   => null
  , X_DOC_ATTRIBUTE15   => null
        , X_CREATE_DOC => 'Y'

  );
  end add_ebs_attachment;	
 
/* *************************************************************************************************************
   *                                             - PROCEDURE update_url -                                      *             
   ************************************************************************************************************* */ 
PROCEDURE update_url
           (errbuf OUT VARCHAR2
            ,retcode OUT NUMBER
			,p_delete_flag IN VARCHAR2) IS

  CURSOR get_ipmversion IS
  SELECT DISTINCT(d1.definition_id)
   FROM  definition@apps2ocs d1
  WHERE d1.name = 'NUCOR EBS IMAGES'
  AND   d1.definition_type = 'Application';

  CURSOR get_url(p_ipmappid number) IS
  select substr(detailvalue,0,(length(detailvalue)-2)) 
  from repository_appdetails@apps2ocs
  where app_id = p_ipmappid
  and detailkey = 'IPM_VIEWER_URL_FORMAT';

  CURSOR get_invoice(c_invoice VARCHAR2) IS
  SELECT invoice_id
  FROM ap_invoices_all
  WHERE invoice_num = c_invoice;

  CURSOR get_wcexp (c_report_id VARCHAR2) IS
  SELECT doc.rowid,
         doc.did,
         doch.ddocname,
         doc.xipm_app_7_0 report_id,
         doc.xipm_app_7_1 file_name,
         doc.xipm_app_7_1 expense_num
  FROM  docmeta@apps2ocs doc
       ,documenthistory@apps2ocs doch
  WHERE doc.did = doch.did
  AND   doc.xipmsys_app_id = 7
  AND doc.xipm_app_7_3 = 'Imported'
  AND doch.daction = 'Checkin'
  AND doc.xipm_app_7_0 = c_report_id
  order by doc.xipm_app_7_0;
  
  cursor get_repository_details(p_impversion number) is
  select ra1.detailvalue doc_app_id, 
         ra2.detailvalue doc_attach_status_field, 
		 ra3.detailvalue doc_pk_field, 
		 ra4.detailvalue doc_entity_name_field,
         ra5.detailvalue doc_title_field, 
		 ra6.detailvalue doc_desc_field, 
		 ra7.detailvalue doc_cat_field,
		 ra8.detailvalue doc_fnd_attach_id_field
    from repository_appdetails@apps2ocs ra1,
         repository_appdetails@apps2ocs ra2,
         repository_appdetails@apps2ocs ra3,
		 repository_appdetails@apps2ocs ra4,
         repository_appdetails@apps2ocs ra5,
         repository_appdetails@apps2ocs ra6,
         repository_appdetails@apps2ocs ra7,
		 repository_appdetails@apps2ocs ra8
   where ra1.app_id = p_impversion
     and ra1.detailkey = 'REPOSITORY_APP_ID'
    -- and dm.xipmsys_app_id = ra1.detailvalue
     and ra2.app_id = p_impversion
     and ra2.detailkey = 'FIELD_11_REPOSITORY_NAME'
     and ra3.app_id = p_impversion
     and ra3.detailkey = 'FIELD_2_REPOSITORY_NAME'
	 and ra4.app_id = p_impversion
	 and ra4.detailkey = 'FIELD_1_REPOSITORY_NAME'
     and ra5.app_id = p_impversion
     and ra5.detailkey = 'FIELD_6_REPOSITORY_NAME'
     and ra6.app_id = p_impversion
     and ra6.detailkey = 'FIELD_7_REPOSITORY_NAME'
     and ra7.app_id = p_impversion
     and ra7.detailkey = 'FIELD_8_REPOSITORY_NAME'
	 and ra8.app_id = p_impversion
     and ra8.detailkey = 'FIELD_12_REPOSITORY_NAME';
	 
  TYPE docrecordtype IS RECORD(entity_name VARCHAR2(200), pk_value NUMBER, drow_id VARCHAR2(200), doc_did NUMBER, doc_title varchar2(200), doc_desc varchar2(200), doc_cat varchar2(200));
  rec_docrecordtype docrecordtype;

  TYPE reptype is TABLE OF docrecordtype INDEX BY BINARY_INTEGER;
  l_reptype reptype;
  
  TYPE docdelrecordtype IS RECORD(entity_name VARCHAR2(200), pk_value NUMBER, drow_id VARCHAR2(200), doc_did NUMBER, doc_title varchar2(200), doc_desc varchar2(200), doc_cat varchar2(200), fnd_attachment_doc_id NUMBER );
  
  TYPE repdeltype is TABLE OF docdelrecordtype INDEX BY BINARY_INTEGER;
  l_repdeltype repdeltype;
  
  l_transaction_id NUMBER;
  l_filename apps.fnd_documents_tl.file_name%TYPE;
  l_url         apps.fnd_documents_tl.file_name%TYPE;
  l_entity_name VARCHAR2(30) := 'OIE_HEADER_ATTACHMENTS';
  l_app_userid NUMBER;
  l_userid NUMBER := apps.fnd_profile.value('USER_ID');
  l_respid NUMBER := apps.fnd_profile.value('RESP_ID');
  l_appid NUMBER := apps.fnd_profile.value('RESP_APPL_ID');
  l_description apps.fnd_documents_tl.description%TYPE;
  l_expense_num ap_expense_report_headers_all.invoice_num%TYPE;
  l_report_id ap_expense_report_headers_all.report_header_id%TYPE;
  l_doc_app_id  NUMBER;
  l_doc_attach_status_field VARCHAR2(30);
  l_doc_pk_field VARCHAR2(30);
  l_imported VARCHAR2(30) := 'Imported';
  l_doc_entity_name_field VARCHAR2(30);
  l_doc_title_field varchar2(30);
  l_doc_desc_field varchar2(30);
  l_doc_cat_field varchar2(30); 
  l_doc_fnd_attach_id_field varchar2(30);  
  l_where_clause  VARCHAR2(200);
  l_select_clause VARCHAR2(500);
  l_from_clause VARCHAR2(200);
  l_order_header_id oe_order_headers.header_id%TYPE;
  l_order_number oe_order_headers.order_number%TYPE;
  l_line_id oe_order_lines_all.line_id%TYPE;
  l_vendor_id ap_suppliers.vendor_id%TYPE;
  l_vendor_site_id ap_supplier_sites_all.vendor_site_id%TYPE;
  l_po_header_id po_headers_all.po_header_id%TYPE;
  l_interface_transaction_id rcv_transactions.interface_transaction_id%TYPE;
  l_po_line_id po_lines_all.po_line_id%TYPE;
  l_delivery_detail_id wsh_delivery_details.delivery_detail_id%TYPE;
  l_delivery_id wsh_new_deliveries.delivery_id%TYPE;
  l_trip_id WSH_TRIPS.trip_id%TYPE;
  l_stop_id wsh_trip_stops.stop_id%TYPE;
  l_update_clause VARCHAR2(500);
  l_set_clause VARCHAR2(200);
  l_sql_up VARCHAR2(1000);		
  l_where_clause_up  VARCHAR2(200);		
  l_delete_flag VARCHAR2(3) := p_delete_flag;
  l_where_del_clause  VARCHAR2(200);
  l_select_del_clause VARCHAR2(500);
  l_from_del_clause VARCHAR2(200);
  l_sql_del VARCHAR2(1000);		
  l_category_id NUMBER;  
		
  l_sql VARCHAR2(1000);

  l_invoice_id ap_invoices_all.invoice_id%TYPE;
  l_status VARCHAR2(1) := 'P';
  r_status VARCHAR2(1) := 'P';
  i_status VARCHAR2(1) := 'P';
  d_status VARCHAR2(30) ;
  l_error  VARCHAR2(240);
  l_ipmversion NUMBER;
  l_img_status VARCHAR2(30);
  l_failed NUMBER   :=0;
  l_rowid VARCHAR2(20);
  l_did   NUMBER;
  l_ddocname    VARCHAR2(20);
  i_count NUMBER := 0;
  l_del_count NUMBER := 0;		

  l_error_message VARCHAR2(2000);
  /* ----------------------------------------------

  l_counter NUMBER :=0;
  l_commit NUMBER  :=0;
  l_linked NUMBER   :=0;



  l_requestid NUMBER;


  ------------------------------------------ */


BEGIN
   fnd_file.put_line (fnd_file.log,'---------- Begin process -----------');

   fnd_file.put_line (fnd_file.output,' ----------------- WCI URL Attachment -------------------- ');
   fnd_file.put_line (fnd_file.output,' Request Id - '|| FND_GLOBAL.CONC_REQUEST_ID);

   fnd_file.put_line(fnd_file.log,'get IPM app id');
   OPEN get_ipmversion;
   FETCH get_ipmversion INTO l_ipmversion;
         IF get_ipmversion%notfound THEN
            l_status := 'E';
            l_error := 'Unable to get IPM version';
        END IF;
   CLOSE get_ipmversion;
   fnd_file.put_line(fnd_file.log,'IPM app id '||l_ipmversion);
   
   --Get IPM View URL Format--
   OPEN get_url(l_ipmversion);
   FETCH get_url INTO l_url;
     IF get_url%notfound THEN
        l_status := 'E';
        l_error := 'Host Name not found in AXF Configs';
     END IF;
   CLOSE get_url;
   
   OPEN get_repository_details(l_ipmversion);
   FETCH get_repository_details INTO l_doc_app_id, l_doc_attach_status_field, l_doc_pk_field, l_doc_entity_name_field, l_doc_title_field, l_doc_desc_field, l_doc_cat_field, l_doc_fnd_attach_id_field ;
      IF get_repository_details%notfound THEN 
	     l_status := 'E';
         l_error := 'Unable to get Repository Details';
      END IF;
   CLOSE get_repository_details;
    fnd_file.put_line(fnd_file.log,'IPM app id '||l_ipmversion);
   
   IF l_status = 'P' THEN
     fnd_file.put_line(fnd_file.log,'get WCI Imported Documents Primary Key');
	 
	 BEGIN
	 --execute immediate 'SELECT COUNT(*) FROM '||var_table_name || ' where  DTM >= '|| var_bgn_date ||' and DTM < '||var_end_date INTO var_total_rows;
	 l_select_clause := 'SELECT DISTINCT '||l_doc_entity_name_field||','||l_doc_pk_field||' ,d.rowid ,d.did ,'||l_doc_title_field||', '||l_doc_desc_field||', '||l_doc_cat_field||' ';
	 l_from_clause := ' FROM docmeta@APPS2OCS d ';
	 l_where_clause  := 'WHERE d.xipmsys_app_id = '|| l_doc_app_id || ' AND d.'|| l_doc_attach_status_field || ' = '|| ' ''Imported'' ' ;
	 l_sql := l_select_clause || l_from_clause || l_where_clause;
	 --execute immediate 'SELECT DISTINCT '|| l_doc_pk_field || ' FROM docmeta@APPS2OCS d  WHERE d.xipmsys_app_id = '|| l_doc_app_id || ' AND d.'|| l_doc_attach_status_field || ' = '|| ' ''Imported'' '   BULK COLLECT INTO l_reptype ; 
	 
	 execute immediate l_sql BULK COLLECT INTO l_reptype;
	 
	 EXCEPTION WHEN no_data_found THEN
		fnd_file.put_line(fnd_file.log,'No Records Found to Process');	
     WHEN OTHERS THEN 
		fnd_file.put_line(fnd_file.log,'Error Getting records to Process');  		
	 END;
	 
     FOR i IN 1 .. l_reptype.COUNT LOOP
     fnd_file.put_line(fnd_file.log,'Processing Primary Key '||l_reptype(i).pk_value||' Of Entity '||l_reptype(i).entity_name);
     fnd_file.put_line (fnd_file.output,' --------------------------------- ');
     fnd_file.put_line (fnd_file.output,'Processing Primary Key '||l_reptype(i).pk_value||' Of Entity '||l_reptype(i).entity_name);
	 
	 r_status := 'P';
     -- check if transaction exists in EBS
	 IF l_reptype(i).entity_name = 'OE_ORDER_HEADERS' THEN
	    
		BEGIN
		   SELECT header_id, order_number
		     INTO l_order_header_id, l_order_number
			 FROM oe_order_headers_all
			WHERE header_id = l_reptype(i).pk_value;
			
	    EXCEPTION 
		  WHEN no_data_found THEN 
	         l_img_status := 'Order Header Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for Order Header image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for Order Header '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' Order Header - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('Order Header '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding Order Header - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END;

	  ELSIF l_reptype(i).entity_name = 'OE_ORDER_LINES'	THEN

         BEGIN
            SELECT line_id
			  INTO l_line_id
			  FROM oe_order_lines_all
			 WHERE line_id = l_reptype(i).pk_value;
			 
	    EXCEPTION 
		  WHEN no_data_found THEN 
	         l_img_status := 'Order Line Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for Order Line image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for Order Line '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' Order Line - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('Order Line '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding Order Line - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END;
		  
      ELSIF l_reptype(i).entity_name = 'PO_VENDORS'	THEN
	    
		 BEGIN
		    SELECT vendor_id
			  INTO l_vendor_id
			  FROM ap_suppliers
			 WHERE vendor_id = l_reptype(i).pk_value;
			 
		 EXCEPTION
 		  WHEN no_data_found THEN 
	         l_img_status := 'Supplier Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for Supplier image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for Supplier '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' Supplier - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('Supplier '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding Supplier - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END;          		 
		  
	  ELSIF l_reptype(i).entity_name = 'PO_VENDOR_SITES' THEN
      
         BEGIN
           SELECT vendor_site_id
             INTO l_vendor_site_id
             FROM ap_supplier_sites_all
            WHERE vendor_site_id = 	l_reptype(i).pk_value;
         EXCEPTION
 		  WHEN no_data_found THEN 
	         l_img_status := 'Supplier Site Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for Supplier Site image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for Supplier Site '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' Supplier Site - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('Supplier Site '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding Supplier Site - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END;  
		  
	  ELSIF l_reptype(i).entity_name = 'RCV_TRANSACTIONS_INTERFACE' THEN
	  
         BEGIN
		    SELECT DISTINCT interface_transaction_id
			  INTO l_interface_transaction_id
			  FROM rcv_transactions
		     WHERE interface_transaction_id = l_reptype(i).pk_value ;
			 
         EXCEPTION
 		  WHEN no_data_found THEN 
	         l_img_status := 'Receipt Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for Receipt image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for Receipt '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' Receipt - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('Receipt '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding Receipt - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END;  			 

	  ELSIF l_reptype(i).entity_name = 'PO_HEADERS' THEN
	  
         BEGIN 
		    SELECT po_header_id
			  INTO l_po_header_id
			  FROM po_headers_all
			 WHERE po_header_id = l_reptype(i).pk_value;

         EXCEPTION
 		  WHEN no_data_found THEN 
	         l_img_status := 'PO Header Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for PO Header image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for PO Header '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' PO Header - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('PO Header '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding PO Header - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END;  
		  
	  ELSIF l_reptype(i).entity_name = 'PO_LINES' THEN
	  
         BEGIN 
		    SELECT po_line_id
			  INTO l_po_line_id
			  FROM po_lines_all
			 WHERE po_line_id = l_reptype(i).pk_value;

         EXCEPTION
 		  WHEN no_data_found THEN 
	         l_img_status := 'PO Line Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for PO Line image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for PO Line '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' PO Line - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('PO Line '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding PO Line - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END;             		  

	  ELSIF l_reptype(i).entity_name = 'WSH_DELIVERY_DETAILS' THEN
	  
         BEGIN 
		    SELECT delivery_detail_id
			  INTO l_delivery_detail_id
			  FROM wsh_delivery_details
			 WHERE delivery_detail_id = l_reptype(i).pk_value;

         EXCEPTION
 		  WHEN no_data_found THEN 
	         l_img_status := 'WSH Delivery Detail Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for WSH Delivery Detail image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for WSH Delivery Detail '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' WSH Delivery Detail - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('WSH Delivery Detail '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding WSH Delivery Detail - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END;     
		  
	  ELSIF l_reptype(i).entity_name = 'WSH_NEW_DELIVERIES' THEN
	  
         BEGIN 
		    SELECT delivery_id
			  INTO l_delivery_id
			  FROM wsh_new_deliveries
			 WHERE delivery_id = l_reptype(i).pk_value;

         EXCEPTION
 		  WHEN no_data_found THEN 
	         l_img_status := 'WSH New Delivery Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for WSH New Delivery image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for WSH New Delivery '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' WSH New Delivery - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('WSH New Delivery '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding WSH New Delivery - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END;  		  
	 
	  ELSIF l_reptype(i).entity_name = 'WSH_TRIPS' THEN
	  
         BEGIN 
		    SELECT trip_id
			  INTO l_trip_id
			  FROM WSH_TRIPS
			 WHERE trip_id = l_reptype(i).pk_value;

         EXCEPTION
 		  WHEN no_data_found THEN 
	         l_img_status := 'WSH Trip Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for WSH Trip image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for WSH Trip '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' WSH Trip - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('WSH Trip '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding WSH Trip - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END;  	

	  ELSIF l_reptype(i).entity_name = 'WSH_TRIP_STOPS' THEN
	  
         BEGIN 
		    SELECT stop_id
			  INTO l_stop_id
			  FROM WSH_TRIP_STOPS
			 WHERE stop_id = l_reptype(i).pk_value;

         EXCEPTION
 		  WHEN no_data_found THEN 
	         l_img_status := 'WSH Trip Stop Missing in EBS';
	         r_status := 'E'; 
	         l_error := 'Can not find EBS record for WSH Trip Stop image '||l_reptype(i).pk_value;
	         fnd_file.put_line(fnd_file.log,'Can not find EBS record for WSH Trip Stop '||l_reptype(i).pk_value);
	         
			 fnd_file.put_line (fnd_file.output,' WSH Trip Stop - '||l_reptype(i).pk_value||' not found in EBS');
	         fnd_file.put_line (fnd_file.output,' --------------------------------- ');
	 
	      WHEN OTHERS THEN
		     r_status := 'E';
	         fnd_file.put_line(fnd_file.log,substr('WSH Trip Stop '||l_reptype(i).pk_value||' not found in EBS',1,240));
	         fnd_file.put_line (fnd_file.output,' Error finding WSH Trip Stop - '||l_reptype(i).pk_value||' in EBS');
			 fnd_file.put_line (fnd_file.output,' --------------------------------- ');
		  END; 	
      END IF; 		

	  BEGIN
		SELECT doch.ddocname
		  INTO l_ddocname
		  FROM documenthistory@apps2ocs doch
	     WHERE doch.did = l_reptype(i).doc_did 
		   AND doch.daction = 'Checkin';
			  
	  EXCEPTION
         WHEN OTHERS THEN
            fnd_file.put_line (fnd_file.output,' Error finding Document Name for Doc Id- '||l_reptype(i).doc_did||' '||SQLERRM);	
            fnd_file.put_line (fnd_file.log,' Error finding Document Name for Doc Id- '||l_reptype(i).doc_did||' '||SQLERRM);
      END;			
		  
      IF r_status = 'P' THEN
         i_count := 0;
         l_rowid := l_reptype(i).drow_id;
         l_did := l_reptype(i).doc_did;
         --l_report_id := rec.report_id;
         l_description := l_reptype(i).doc_desc; 
         i_count := i_count + 1;
         l_filename   := l_url||l_ipmversion||'.'||l_ddocname;

         fnd_file.put_line(fnd_file.log,'File name '||l_filename);

		 --Call  Procedure add_ebs_attachment to attach image to EBS transaction
         begin

           add_ebs_attachment(l_reptype(i).pk_value,l_description, l_filename, l_reptype(i).entity_name, l_reptype(i).doc_cat, l_reptype(i).doc_title,l_userid,l_respid,l_appid );
           l_img_status := 'Linked';
            
           fnd_file.put_line(fnd_file.log,'URL attached');
								 
           --fnd_file.put_line (fnd_file.output,'URL '||i_count||'  attached');
           begin
		      
              l_update_clause := 'UPDATE docmeta@apps2ocs d';
			  l_set_clause := ' SET '||l_doc_attach_status_field||' = ''Linked'' ';
			  l_where_clause_up  := 'WHERE d.xipmsys_app_id = '|| l_doc_app_id || ' AND d.' || l_doc_pk_field || ' = '|| ' :1 ' || ' AND d.' || l_doc_entity_name_field || ' = '|| ' :2 ' ;
			  l_sql_up := l_update_clause || l_set_clause || l_where_clause_up;
			  
			  execute immediate l_sql_up USING l_reptype(i).pk_value, l_reptype(i).entity_name;			  
			  i_status := 'P';
              fnd_file.put_line(fnd_file.log,'WCI record updated for did '||l_did);
           exception
              WHEN OTHERS THEN
                 i_status := 'E';
				 
                 fnd_file.put_line(fnd_file.log,'Failed to update record in WCI for Transaction '||l_reptype(i).pk_value);

           end;
         exception
            when others then
               i_status := 'E';
               fnd_file.put_line(fnd_file.log,'Can not attach url for Transaction '||l_reptype(i).pk_value);
			   
			   retcode := 1;
			   errbuf := SUBSTR('Can not attach url for Transaction  '||SQLERRM,1,240);
         end;
		 
    /*     IF i_status = 'P' AND l_delete_flag = 'Y' THEN

            begin
               --  fnd_file.put_line(fnd_file.log,' Deleting prior images for transaction id '||l_transaction_id);
               XXNUC_EXT_BLOB_TO_FILE_PKG.delete_document(l_reptype(i).pk_value,
			                                              l_reptype(i).entity_name,
														  l_reptype(i).doc_cat,
                                                          d_status,
                                                          l_error_message);

               fnd_file.put_line(fnd_file.log, 'Delete status for transaction '||l_reptype(i).pk_value||' - '||d_status);
                                               --  fnd_file.put_line(fnd_file.log, l_error);
               IF d_status = 'S' THEN
                  fnd_file.put_line (fnd_file.output,' EBS image deleted ');
                  fnd_file.put_line (fnd_file.output,' Transaction - '||l_reptype(i).pk_value||' URL attachment completed');
                  fnd_file.put_line (fnd_file.output,' --------------------------------- ');
               END IF;
            exception
               WHEN OTHERS THEN
                  fnd_file.put_line (fnd_file.output,' EBS image delete function failed ');
                  fnd_file.put_line (fnd_file.output,' --------------------------------- ');
                  --  l_error  := 'Can not delete EBS Image status for Report '||l_transaction_id;
                  fnd_file.put_line(fnd_file.log,'Failed to delete image in EBS for Transaction '||l_reptype(i).pk_value);
            end;
         END IF; */
		 

       END IF;
       /*IF d_status = 'S' THEN
          COMMIT;
       ELSE
          ROLLBACK;
       END IF;*/
	   COMMIT;
     END LOOP;
	 
	 IF l_delete_flag = 'Y' THEN 
	    BEGIN
		
		   l_select_del_clause := 'SELECT DISTINCT '||l_doc_entity_name_field||','||l_doc_pk_field||' ,d.rowid ,d.did ,'||l_doc_title_field||', '||l_doc_desc_field||', '||l_doc_cat_field||', '||l_doc_fnd_attach_id_field||' ';
	       l_from_del_clause := ' FROM docmeta@APPS2OCS d ,fnd_attached_documents a ';
	       l_where_del_clause  := 'WHERE d.xipmsys_app_id = '|| l_doc_app_id || ' AND d.'|| l_doc_attach_status_field || ' = '|| ' ''Linked'' '||'AND a.attached_document_id = d.'||l_doc_fnd_attach_id_field||' AND a.attribute15 = ''Y'' ' ;
	       l_sql_del := l_select_del_clause || l_from_del_clause || l_where_del_clause;
		   
		   execute immediate l_sql_del BULK COLLECT INTO l_repdeltype;
		   
	    EXCEPTION WHEN no_data_found THEN
		   fnd_file.put_line(fnd_file.log,'No Records Found to Delete');		
		WHEN OTHERS THEN 
		   fnd_file.put_line(fnd_file.log,'Error Getting records to be deleted');  		
		END;
		 
		FOR i IN 1 .. l_repdeltype.COUNT LOOP
		   l_category_id := NULL;
		   
			BEGIN
		       select category_id
                into  l_category_id
               from   APPS.fnd_document_categories_tl fdc
               WHERE  fdc.user_name = l_repdeltype(i).doc_cat
                 and  language = 'US';
		    EXCEPTION
               WHEN OTHERS THEN
                  l_category_id := NULL;
            END;
			
			
		    begin
               XXNUC_EXT_BLOB_TO_FILE_PKG.delete_document(l_repdeltype(i).pk_value,
			                                              l_repdeltype(i).entity_name,
														  l_category_id,
														  l_repdeltype(i).fnd_attachment_doc_id,
                                                          d_status,
                                                          l_error_message);

               fnd_file.put_line(fnd_file.log, 'Delete status for transaction '||l_repdeltype(i).pk_value||' - '||d_status);
			   l_del_count := l_del_count +1;
                                               --  fnd_file.put_line(fnd_file.log, l_error);
               IF d_status = 'S' THEN
                  fnd_file.put_line (fnd_file.output,' EBS image deleted ');
                  fnd_file.put_line (fnd_file.output,' Transaction - '||l_repdeltype(i).pk_value||' URL attachment completed');
                  fnd_file.put_line (fnd_file.output,' --------------------------------- ');
               END IF;
            exception
               WHEN OTHERS THEN
                  fnd_file.put_line (fnd_file.output,' EBS image delete function failed '||SQLERRM);
                  fnd_file.put_line (fnd_file.output,' --------------------------------- ');
                  --  l_error  := 'Can not delete EBS Image status for Report '||l_transaction_id;
                  fnd_file.put_line(fnd_file.log,'Failed to delete image in EBS for Transaction '||l_repdeltype(i).pk_value);
            end;
           IF d_status = 'S' THEN
              COMMIT;
           ELSE
              ROLLBACK;
           END IF;
		   
        END LOOP;	
        fnd_file.put_line (fnd_file.output,' No of file attachments deleted from EBS '|| l_del_count);		
	 END IF;
	 	 
  END IF;
  

  EXCEPTION
     WHEN OTHERS THEN
       errbuf := SUBSTR('Failed processing attach WCI URL  '||SQLERRM,1,240);
       retcode := 2;

  END update_url;
END  XXNUC_IMGURL_PKG;