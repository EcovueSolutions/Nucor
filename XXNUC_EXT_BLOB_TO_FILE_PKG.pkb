create or replace PACKAGE BODY      XXNUC_EXT_BLOB_TO_FILE_PKG
AS
-------------------------------------------------------------------------------------------------------------------------------------------------
/* $Header: XXNUC_EXT_BLOB_TO_FILE_PKG.pkb    $ */
/* ***************************************************************************************************************
   *                           - NUCOR -                                                                       *
   ***************************************************************************************************************
   * Application     : Sales, purchasing, AP                                                                     *
   * Program Name    : XXNUC_EXT_BLOB_TO_FILE_PKG.pkb                                                            *
   * Title           : NUCOR EBS attachment File Extract                                                         *
   *                                                                                                             *
   * Utility         : SQL*Plus                                                                                  *
   * Created by      : Soni Jonna                                                                                *
   * Creation Date   : 20-Jan-2017                                                                               *
   * Description     :                                                                                           *
   *                                                                                                             *
   * Change History:                                                                                             *
   *                                                                                                             *
   *============================================================================================================ *
   * Version    |Date           | Name                          | Remarks                                        *
   *============================================================================================================ *
   * 1.0        |20-Jan-2017    |Soni Jonna                     | Initial Version                                *
   ***************************************************************************************************************
*/
  -------------------------------------------------------------------------------------------------------------------------------------------------
  
PROCEDURE get_wsh_metadatafields (p_entity_name IN varchar2,
                                  p_pk_value IN number,
								  p_tran_num OUT varchar2,
								  p_cust_num OUT varchar2,
								  p_org_id OUT NUMBER
                                   )  IS
BEGIN
   
   fnd_file.put_line (fnd_file.log,'Inside Procedure get_wsh_metadatafields for Entity '||p_entity_name ||' And Primary Key '|| p_pk_value);
   IF p_entity_name = 'WSH_DELIVERY_DETAILS' THEN
		      
	  BEGIN
		select distinct to_char(ooh.order_number), hca.account_number, wdd.org_id
		  into p_tran_num, p_cust_num, p_org_id
          from wsh_delivery_details wdd,
               oe_order_headers_all ooh,
               hz_cust_accounts hca
        where 1=1
          and delivery_detail_id = p_pk_value
          and ooh.header_id(+) = wdd.source_header_id
          and hca.cust_account_id(+) = wdd.customer_id
		  and rownum = 1;

	  EXCEPTION
		 WHEN OTHERS THEN
			p_tran_num := NULL;
			p_cust_num := NULL;
			p_org_id := NULL;
			fnd_file.put_line (fnd_file.log,'Error While deriving Order number and customer number for WSH_DELIVERY_DETAILS Transaction Id: '||p_pk_value);
	 END;
   ELSIF p_entity_name = 'WSH_NEW_DELIVERIES' THEN	
              
	  BEGIN
		 select distinct to_char(ooh.order_number) trans_num, hca.account_number, wnd.organization_id 
		   into p_tran_num, p_cust_num, p_org_id
           from wsh_new_deliveries wnd ,
                wsh_delivery_assignments wda,
                wsh_delivery_details wdd,
                oe_order_headers_all ooh,
                hz_cust_accounts hca
         where 1=1
           and wnd.delivery_id = p_pk_value 
           and wda.delivery_id = wnd.delivery_id
           and wdd.delivery_detail_id = wda.delivery_detail_id
           and ooh.header_id(+) = wdd.source_header_id
           and hca.cust_account_id(+) = wdd.customer_id
		   and rownum = 1;				   
				   
	   EXCEPTION
		  WHEN OTHERS THEN
			 p_tran_num := NULL;
			 p_cust_num := NULL;
			 p_org_id := NULL;
			 fnd_file.put_line (fnd_file.log,'Error While deriving Order number and customer number for WSH_NEW_DELIVERIES Transaction Id: '||p_pk_value);
	   END;  
   ELSIF p_entity_name = 'WSH_TRIPS' THEN	

	  BEGIN
         select distinct to_char(ooh.order_number) trans_num, hca.account_number meta_data1, wdd.org_id
		   into p_tran_num, p_cust_num, p_org_id
           from wsh_trips wt,
                wsh_trip_stops pickup_stop,
                wsh_delivery_legs dl,
                wsh_delivery_assignments wda,
                wsh_delivery_details wdd,
                oe_order_headers_all ooh,
                hz_cust_accounts hca
          where wt.trip_id = p_pk_value
            and pickup_stop.trip_id = wt.trip_id
            and dl.pick_up_stop_id  = pickup_stop.stop_id
            and wda.delivery_id   = dl.delivery_id
            and wdd.delivery_detail_id = wda.delivery_detail_id
            and ooh.header_id = wdd.source_header_id
            and hca.cust_account_id = wdd.customer_id
			and rownum = 1;				   

	   EXCEPTION
		 WHEN OTHERS THEN
			p_tran_num := NULL;
			p_cust_num := NULL;
			p_org_id := NULL;
			fnd_file.put_line (fnd_file.log,'Error While deriving Order number and customer number for WSH_TRIPS Transaction Id: '||p_pk_value);
			  END;  		   
		   
   ELSIF p_entity_name = 'WSH_TRIP_STOPS' THEN	
	   
	  BEGIN
         select distinct to_char(ooh.order_number) trans_num, hca.account_number meta_data1, wdd.org_id
		  into p_tran_num, p_cust_num, p_org_id
          from wsh_trip_stops pickup_stop,
               wsh_delivery_legs dl,
               wsh_delivery_assignments wda,
               wsh_delivery_details wdd,
               oe_order_headers_all ooh,
               hz_cust_accounts hca
         where pickup_stop.stop_id = p_pk_value
           and dl.pick_up_stop_id  = pickup_stop.stop_id
           and wda.delivery_id   = dl.delivery_id
           and wdd.delivery_detail_id = wda.delivery_detail_id
           and ooh.header_id = wdd.source_header_id
           and hca.cust_account_id = customer_id
		   and rownum = 1;
			   

	   EXCEPTION
		  WHEN OTHERS THEN
			 p_tran_num := NULL;
			 p_cust_num := NULL;
			 p_org_id := NULL;
			 fnd_file.put_line (fnd_file.log,'Error While deriving Order number and customer number for WSH_TRIP_STOPS Transaction Id: '||p_pk_value);
	   END;  	
   END IF;
EXCEPTION WHEN OTHERS THEN
   fnd_file.put_line (fnd_file.log,'Error in Procedure get_wsh_metadatafields: '||SQLERRM );

END  get_wsh_metadatafields; 								   
								   

PROCEDURE EXT_BLOB_TO_FILE_PRC(p_errbuf OUT VARCHAR2, 
                               p_retcode OUT NUMBER, 
							   p_reprocess_flag IN VARCHAR2,
                               p_entity_name IN VARCHAR2,									 
							   p_tranaction_id IN NUMBER							   
 							   )
AS

   cursor file_attachments_cur 
   is
     select  flb.file_data , flb.file_name,flb.file_id,dbms_lob.getlength (flb.file_data) f_size, fdt.title, fdt.description, fdc.user_name doc_category, fad.pk1_value, fad.entity_name, fad.attached_document_id, substr(entity_name,1,instr(entity_name,'_',1)-1) ebsmodule
       from  fnd_lobs flb,
             fnd_attached_documents fad,
             fnd_documents fd,
             fnd_documents_tl fdt,
             fnd_document_categories_tl fdc,
             FND_DOCUMENT_DATATYPES fdd			 
       where 1=1
         and fad.document_id = fd.document_id
		 and fdt.document_id = fd.document_id
		 and fdt.language = 'US'
		 and fdc.category_id = fd.category_id
		 and fdc.language = 'US'
		 and fdd.name = 'FILE'
		 and fd.datatype_id = fdd.datatype_id
         and flb.file_id = fd.media_id
		 and p_reprocess_flag = 'N'
		 and nvl(fad.attribute15,'X') <> 'Y'
         and fad.entity_name IN ('OE_ORDER_LINES', 'OE_ORDER_HEADERS', 'PO_VENDORS', 'PO_VENDOR_SITES','PO_HEADERS', 'PO_LINES', 'RCV_TRANSACTIONS_INTERFACE','WSH_DELIVERY_DETAILS','WSH_NEW_DELIVERIES','WSH_TRIPS','WSH_TRIP_STOPS')
		 --and rownum < 10		 
	  union all
	  select flb.file_data , flb.file_name,flb.file_id,dbms_lob.getlength (flb.file_data) f_size, fdt.title, fdt.description, fdc.user_name doc_category, fad.pk1_value, fad.entity_name, fad.attached_document_id, substr(entity_name,1,instr(entity_name,'_',1)-1) ebsmodule 
       from  fnd_lobs flb,
             fnd_attached_documents fad,
             fnd_documents fd,
             fnd_documents_tl fdt,
             fnd_document_categories_tl fdc,
             FND_DOCUMENT_DATATYPES fdd				 
       where 1=1
         and fad.document_id = fd.document_id
		 and fdt.document_id = fd.document_id
		 and fdt.language = 'US'
		 and fdc.category_id = fd.category_id
		 and fdc.language = 'US'
		 and fdd.name = 'FILE'
		 and fd.datatype_id = fdd.datatype_id
         and flb.file_id = fd.media_id
		 and p_reprocess_flag = 'Y'
         and fad.entity_name = p_entity_name
		 and fad.pk1_value = p_tranaction_id
		 order by entity_name;
	    
	cursor trans_details_cur(p_pk_value number, p_entity_name varchar2)
	is 
      select ooh.header_id Primary_key, to_char(ooh.order_number) trans_num,ooh.creation_date, hca.account_number meta_data1, ooh.org_id org_id
        from oe_order_headers_all ooh,
		     hz_cust_accounts hca
       where 1=1
	     and ooh.header_id = p_pk_value
	     and hca.cust_account_id = ooh.sold_to_org_id
         and p_entity_name = 'OE_ORDER_HEADERS'
	  union all
      select ool.line_id primary_key, to_char(ooh.order_number) trans_num, ooh.creation_date, hca.account_number meta_data1, ool.org_id org_id
        from oe_order_lines_all ool,
		     oe_order_headers_all ooh,
			 hz_cust_accounts hca
	   where 1=1
	     and ool.line_id = p_pk_value
	     and ooh.header_id = ool.header_id 
	     and hca.cust_account_id = ooh.sold_to_org_id
		 and p_entity_name = 'OE_ORDER_LINES'		 
	  union all
      select aps.vendor_id primary_key, aps.segment1 trans_num, aps.creation_date, NULL meta_data1, NULL org_id
        from ap_suppliers aps
       where 1=1
	     and aps.vendor_id = p_pk_value     
         and p_entity_name = 'PO_VENDORS'         	
      union all
	  select assa.vendor_site_id primary_key, aps.segment1 trans_num, assa.creation_date, NULL meta_data1, assa.org_id org_id
	    from ap_supplier_sites_all assa,
		     ap_suppliers aps
	   where 1=1
	     and assa.vendor_site_id = p_pk_value
		 and aps.vendor_id = assa.vendor_id
         and p_entity_name = 'PO_VENDOR_SITES'
	  union all
	  select distinct rt.interface_transaction_id primary_key, pha.segment1 trans_num, rt.creation_date, aps.segment1 meta_data1, pha.org_id org_id
	    from rcv_transactions rt, 
		     po_headers_all pha,
			 ap_suppliers aps
	   where 1=1
	     and rt.interface_transaction_id = p_pk_value
		 and pha.po_header_id(+) = rt.po_header_id
		 and aps.vendor_id(+) = rt.vendor_id
		 and p_entity_name = 'RCV_TRANSACTIONS_INTERFACE' 	 
      union all
 	  select pha.po_header_id primary_key, pha.segment1 trans_num, pha.creation_date, aps.segment1 meta_data1, pha.org_id org_id
        from po_headers_all pha,
		     ap_suppliers aps
       where 1=1
         and pha.po_header_id = p_pk_value
		 and aps.vendor_id(+) = pha.vendor_id
         and p_entity_name = 'PO_HEADERS' 
      union all
      select pll.po_line_id primary_key, ph.segment1 trans_num, pll.creation_date, aps.segment1 meta_data1, pll.org_id org_id
        from po_lines_all pll,
		     po_headers_all ph,
			 ap_suppliers aps
       where 1=1
         and pll.po_line_id = p_pk_value
         and ph.po_header_id = pll.po_header_id
         and aps.vendor_id = ph.vendor_id
         and p_entity_name = 'PO_LINES'
	  union all
      select wdd.delivery_detail_id primary_key, NULL trans_num, wdd.creation_date, NULL meta_data1, wdd.org_id org_id
        from wsh_delivery_details wdd
       where 1=1
         and delivery_detail_id = p_pk_value
         and p_entity_name = 'WSH_DELIVERY_DETAILS'
      union all
      select wnd.delivery_id primary_key, NULL trans_num, wnd.creation_date, NULL meta_data1, wnd.organization_id org_id
        from wsh_new_deliveries wnd              
       where 1=1
         and wnd.delivery_id = p_pk_value 
         and p_entity_name = 'WSH_NEW_DELIVERIES'	 
      union all
      select distinct wt.trip_id primary_key, NULL trans_num, wt.creation_date, NULL meta_data1, NULL org_id 
        from wsh_trips wt             
       where wt.trip_id = p_pk_value
         and p_entity_name = 'WSH_TRIPS'
      union all
      select distinct pickup_stop.stop_id primary_key, NULL trans_num, pickup_stop.creation_date, NULL meta_data1, NULL org_id 
        from wsh_trip_stops pickup_stop            
       where pickup_stop.stop_id = p_pk_value
         and p_entity_name = 'WSH_TRIP_STOPS' 	  ;
		 
		 
   vblob                       BLOB;
   vstart                      NUMBER             := 1;
   bytelen                     NUMBER             := 32000;
   l_len                       NUMBER;
   my_vr                       RAW (32000);
   x                           NUMBER;
   v_file_name                 VARCHAR2 (256);
   l_output                    UTL_FILE.file_type;

   l_tot_count                 Number := 0;
   l_dir_path                  varchar2(2000);
   l_err_cnt                   Number:=0;
   l_suc_cnt                   Number:=0;

   gc_utl_handle               UTL_FILE.FILE_TYPE;
   lc_file_name                VARCHAR2(240);
   gr_record                   VARCHAR2(32767);
   l_req_id                    NUMBER         := fnd_global.conc_request_id;
   l_user_id                   NUMBER         := fnd_global.user_id;	
   l_attach_cnt                NUMBER := 0;
   l_trans_num                 oe_order_headers_all.order_number%TYPE;
   l_meta_data1                hz_cust_accounts.account_number%TYPE;
   
   BEGIN   
   BEGIN
     SELECT directory_path
     INTO l_dir_path
     FROM all_directories
     where directory_name = 'XXNUCORWCI';
        Exception when others then
        l_dir_path := Null;
     END;

     fnd_file.put_line (fnd_file.output,'******************************* Start of images to WCI  Nightly Batch Process *******************************');

     fnd_file.put_line (fnd_file.output, 'Start Time:- ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS AM'));

     fnd_file.put_line (fnd_file.output,'--------------------------------------------------------------');
     


     FOR file_attachments_rec IN file_attachments_cur LOOP
	    
		l_attach_cnt := l_attach_cnt + 1;
		lc_file_name := 'EBSIndex_'||file_attachments_rec.ebsmodule||'_'||l_req_id||'.txt'  ;
		
		gc_utl_handle := UTL_FILE.FOPEN(
                            location        => 'XXNUCORWCI'
                           ,filename        => lc_file_name
                           ,open_mode       => 'A' );

		FOR trans_details_rec IN trans_details_cur(file_attachments_rec.pk1_value, file_attachments_rec.entity_name ) LOOP	 

		   --Get Order Number and customer number for WSH entities
		   IF file_attachments_rec.entity_name = 'WSH_NEW_DELIVERIES' OR file_attachments_rec.entity_name = 'WSH_DELIVERY_DETAILS' OR file_attachments_rec.entity_name = 'WSH_TRIPS' OR file_attachments_rec.entity_name = 'WSH_TRIP_STOPS' 
		   THEN
		      get_wsh_metadatafields (file_attachments_rec.entity_name,
			                          file_attachments_rec.pk1_value,
									  trans_details_rec.trans_num,
									  trans_details_rec.meta_data1,
									  trans_details_rec.org_id
			                          );
		   END IF;
		   
           fnd_file.put_line (fnd_file.output,'Entity Name :- '||file_attachments_rec.entity_name);
		   fnd_file.put_line (fnd_file.output,'Transaction id :- '||trans_details_rec.Primary_key);
		   fnd_file.put_line (fnd_file.output,'Transaction Number :- '||trans_details_rec.trans_num);		   
           fnd_file.put_line (fnd_file.output,'Transaction Creation Date :- '||trans_details_rec.creation_date);
           fnd_file.put_line (fnd_file.output,'--------------------------------------------------------------');    

 	  
          fnd_file.new_line(fnd_file.output, 1) ;
          fnd_file.put_line (fnd_file.output,'File Name  :- '||file_attachments_rec.file_name);

          v_file_name := file_attachments_rec.entity_name||'_'||trans_details_rec.Primary_key||'_'||l_attach_cnt||'_'||file_attachments_rec.file_name;
          l_len       := file_attachments_rec.f_size;
          vblob       := file_attachments_rec.file_data;
          l_tot_count := l_tot_count +1;

          l_output := UTL_FILE.fopen ('XXNUCORWCI', v_file_name, 'wb', 32760);
          vstart := 1;
          bytelen := 32000;
          x := l_len;

          Begin

            IF l_len < 32760
            THEN
               UTL_FILE.put_raw (l_output, vblob);
               UTL_FILE.fflush (l_output);
               UTL_FILE.fclose (l_output);

               l_suc_cnt := l_suc_cnt +1;
            ELSE
               vstart := 1;

               WHILE vstart < l_len AND bytelen > 0
               LOOP
               DBMS_LOB.READ (vblob, bytelen, vstart, my_vr);
               UTL_FILE.put_raw (l_output, my_vr);
               UTL_FILE.fflush (l_output);
               vstart := vstart + bytelen;
               x := x - bytelen;

               IF x < 32000
               THEN
                  bytelen := x;
               END IF;

               NULL;
               END LOOP;

               l_suc_cnt := l_suc_cnt +1;

               UTL_FILE.fclose (l_output);
            END IF;

            fnd_file.put_line (fnd_file.output,'File Conversion   :- Completed');
            fnd_file.put_line (fnd_file.output,'File Migrated to shared drive   :- Completed');

          Exception when others then
             fnd_file.put_line (fnd_file.output,'File Conversion   :- Error '||SQLERRM);
             fnd_file.put_line (fnd_file.log,'Error at File Conversion for the entity: '||file_attachments_rec.entity_name||' Transaction '||trans_details_rec.trans_num||' : '|| SQLERRM);
             l_err_cnt := l_err_cnt + 1;
          end;


          gr_record := l_dir_path||'/'||v_file_name||'|'||file_attachments_rec.entity_name||'|'||trans_details_rec.primary_key||'|'||trans_details_rec.trans_num||'|'||trans_details_rec.org_id||'|'||trans_details_rec.meta_data1||'|'||file_attachments_rec.title||'|'||file_attachments_rec.description||'|'||file_attachments_rec.doc_category||'|'||file_attachments_rec.attached_document_id||'|'||'Direct'||'|'||file_attachments_rec.file_name||'|'||'Imported'||'|';


          UTL_FILE.PUT_LINE(gc_utl_handle,gr_record);

          fnd_file.put_line (fnd_file.output,'Migrated File Name  :- '||v_file_name); 		 
	      	
		  
        END LOOP;  
     fnd_file.put_line (fnd_file.output,'--------------------------------------------------------------');
     UTL_FILE.FCLOSE(gc_utl_handle);
	 --if p_reprocess_flag = 'N' then
	    
        begin
		  update fnd_attached_documents
             set attribute15 = 'Y'
	             ,last_updated_by = l_user_id
                 ,last_update_date = sysdate
            where attached_document_id = file_attachments_rec.attached_document_id;
        Exception when others then
           fnd_file.put_line (fnd_file.log,'Error in Flag update for the document attachment '||file_attachments_rec.attached_document_id||' : '|| SQLERRM);
        End;	 
         	    
	 --end if;
	 Commit;	
	 
     END LOOP;     

     fnd_file.put_line (fnd_file.output,'Shared drive location  :- '||l_dir_path);
     fnd_file.put_line (fnd_file.output,'No of Attachments selected for conversion  :- '||l_attach_cnt);
     fnd_file.put_line (fnd_file.output,'No of image file conversion completed  :- '||l_suc_cnt);
     fnd_file.put_line (fnd_file.output,'No of Errors :- '||l_err_cnt);
     fnd_file.put_line (fnd_file.output, 'End Time:- ' || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH:MI:SS AM'));
     fnd_file.put_line (fnd_file.output,'******************************* End of  images to WCI Nightly Batch Process *******************************');
  EXCEPTION
    WHEN OTHERS
    THEN
	  p_retcode := 2;	
	  p_errbuf := 'Error in EXT_BLOB_TO_FILE_PRC Program : ' || SQLERRM;
      fnd_file.put_line (fnd_file.log,'Error in EXT_BLOB_TO_FILE_PRC Program : ' || SQLERRM);
  END EXT_BLOB_TO_FILE_PRC;


  PROCEDURE DELETE_DOCUMENT(p_pk_value IN NUMBER, p_entity_name IN VARCHAR2, p_doc_cat IN VARCHAR2, p_fnd_attachment_doc_id IN NUMBER, p_status OUT VARCHAR2, p_error_message OUT VARCHAR2)
  AS
  
   cursor doc_cur is
   SELECT fd.document_id,fd.datatype_id
     FROM fnd_documents fd,
          fnd_attached_documents fad,
          FND_DOCUMENT_DATATYPES fdd          
    WHERE 1=1
      AND fad.document_id = fd.document_id
	  AND fdd.name = 'FILE'
	  AND fd.datatype_id = fdd.datatype_id
      AND fad.pk1_value = p_pk_value
      AND fad.entity_name = p_entity_name  
      AND fad.category_id = p_doc_cat	
      AND fad.attached_document_id = p_fnd_attachment_doc_id 	 
      AND fad.attribute15 = 'Y'	  
      AND media_id is not null; 
	  
   l_err_cnt number := 0;

   BEGIN
      
      FOR doc_rec in doc_cur LOOP
         BEGIN
           fnd_documents_pkg.delete_row(doc_rec.document_id,doc_rec.datatype_id,'Y');
         EXCEPTION
            WHEN OTHERS
            THEN
               rollback;
             --fnd_file.put_line (fnd_file.log,'Error in Main Program : ' || SQLERRM);
               p_error_message :=  p_error_message||' : '||SQLERRM;
               l_err_cnt := l_err_cnt + 1;
         END;
      END LOOP;
      Commit;
      IF l_err_cnt <> 0 THEN
         p_status := 'E';
      ELSE
         p_status := 'S';
      END IF;
	  
   EXCEPTION
      WHEN OTHERS THEN 
	    p_status := 'E';
      	fnd_file.put_line (fnd_file.log,'Error in Delete Document : ' || SQLERRM);
		p_error_message :=  p_error_message||' : '||SQLERRM;
   END DELETE_DOCUMENT;
END XXNUC_EXT_BLOB_TO_FILE_PKG;