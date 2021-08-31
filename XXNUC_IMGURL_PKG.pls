create or replace PACKAGE   XXNUC_IMGURL_PKG AS
PROCEDURE update_url(errbuf OUT VARCHAR2
				   ,retcode OUT NUMBER
				   ,p_delete_flag IN VARCHAR2) ;
PROCEDURE add_ebs_attachment(pk_value IN NUMBER,
                       doc_description IN VARCHAR2,
 					   URL IN VARCHAR2,
 					   entity_name IN VARCHAR2,
					   doc_category IN VARCHAR2,
					   doc_title IN VARCHAR2,
					   appuserid IN NUMBER,
					   respid IN NUMBER,
					   appid IN NUMBER );							 
END XXNUC_IMGURL_PKG;