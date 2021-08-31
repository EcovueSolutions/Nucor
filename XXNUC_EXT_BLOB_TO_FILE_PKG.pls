create or replace PACKAGE      XXNUC_EXT_BLOB_TO_FILE_PKG
AUTHID CURRENT_USER AS
-------------------------------------------------------------------------------------------------------------------------------------------------
/* $Header: XXNUC_EXT_BLOB_TO_FILE_PKG.pks    $ */
/* ***************************************************************************************************************
   *                           - NUCOR -                                                                       *
   ***************************************************************************************************************
   * Application     : Sales, purchasing, AP                                                                     *
   * Program Name    : XXNUC_EXT_BLOB_TO_FILE_PKG.pks                                                            *
   * Title           : NUCOR EBS attachment File Extract                                                                        *
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

PROCEDURE EXT_BLOB_TO_FILE_PRC(p_errbuf OUT VARCHAR2, 
                               p_retcode OUT NUMBER, 
							   p_reprocess_flag IN VARCHAR2,
                               p_entity_name IN VARCHAR2,									 
							   p_tranaction_id IN NUMBER							   
 							   );
PROCEDURE DELETE_DOCUMENT(p_pk_value IN NUMBER, p_entity_name IN VARCHAR2, p_doc_cat IN VARCHAR2, p_fnd_attachment_doc_id IN NUMBER, p_status OUT VARCHAR2, p_error_message OUT VARCHAR2);
PROCEDURE get_wsh_metadatafields (p_entity_name IN varchar2,
                                  p_pk_value IN number,
								  p_tran_num OUT varchar2,
								  p_cust_num OUT varchar2,
								  p_org_id OUT NUMBER
                                   );
END XXNUC_EXT_BLOB_TO_FILE_PKG;