  import { useEffect, useState } from 'react';
  import { FaFileAlt } from 'react-icons/fa'; 
  import axiosClient from './api/axiosClient'; // Adjust the import path as necessary
  import { Auth } from 'aws-amplify';
  import cleanFileName from './CleanFileName';

  export default function SubmittedDocuments() {
    const [documents, setDocuments] = useState([]);
    const [previewUrl, setPreviewUrl] = useState(null);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [selectedDocId, setSelectedDocId] = useState(null);

    useEffect(() => {
      let called = false;
      const fetchDocs = async () => {
        if(called) return;
        called = true;

        const user = await Auth.currentAuthenticatedUser();
        await axiosClient.post('/getSubmittedDocuments', { "user_id": user.attributes.sub }).then((response) => {
            console.log(response.data)
            setDocuments(response.data["documents"]);
        }).catch((error) => {
            console.error('Error fetching documents:', error);
            setDocuments([]); // Set to empty array on error
        });
      };

      fetchDocs();
    }, []);

    async function handlePreview(documentId) {
      try {
        const response = await axiosClient.post('/getViewDocumentUrl', {
          "file_name": documentId,
        });

        setPreviewUrl(response.data["url"]);
        setSelectedDocId(documentId)
        setIsModalOpen(true);
      } catch (error) {
        console.error('Error fetching preview URL:', error);
        alert('Unable to load document preview.');
      }
    }


    return (
        <div className="w-full space-y-2">
        {documents.length === 0 ? (
          <p className="text-center text-gray-500 py-8">No Documents Submitted</p>
        ) : (
          documents.map((doc) => (
            <div
              key={doc.documentId}
              className="flex items-center justify-between border-b border-gray-300 py-3"
            >
              <div className="flex flex-1 items-center gap-4">
                <span className="w-1/3 font-medium text-gray-800">{cleanFileName(doc.documentId)}</span>
                <span className="w-1/3 text-sm text-gray-500">{new Date(doc.submittedAt).toLocaleString()}</span>
                <div className="w-1/3 flex flex-wrap gap-2">
                  {doc.approvers.map((approver, index) => (
                    <span
                      key={index}
                      className="px-2 py-0.5 text-sm text-gray-700 bg-white/60 rounded-[5px] border border-gray-300"
                    >
                      {approver.approverEmail}
                    </span>
                  ))}
                </div>
              </div>
              <button
                onClick={() => handlePreview(doc.documentId)}
                className="text-blue-600 hover:text-blue-800 text-xl"
                title="View Document"
              >
                <FaFileAlt
                  className={`text-xl ${
                    doc.finalStatus === 'APPROVED'
                      ? 'text-green-600'
                      : doc.finalStatus === 'PENDING'
                      ? 'text-yellow-500'
                      : 'text-red-600'
                  } hover:text-black`}
                />
              </button>
            </div>
          ))
        )}

        {/* Modal Preview */}
        {isModalOpen && (
          <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm flex items-center justify-center">
            <div className="bg-white rounded-lg p-6 max-w-3xl w-full relative pt-10 px-6 pb-6">
              <button
                onClick={() => setIsModalOpen(false)}
                className="absolute top-2 right-3 text-gray-500 hover:text-red-500 text-xl font-bold"
              >
                &times;
              </button>

              {/* Document Preview */}
              <iframe
                src={previewUrl}
                title="Document Preview"
                className="w-full h-[70vh] border rounded mb-6"
              />

              {/* Approver Status List */}
              <div className="space-y-3">
                <h3 className="text-lg font-semibold text-gray-800 border-b pb-1">Approvers</h3>
                {documents
                  .find((doc) => doc.documentId === selectedDocId)
                  ?.approvers.map((approver, idx) => (
                    <div
                      key={idx}
                      className="flex justify-between items-center border-b border-gray-300 py-2"
                    >
                      <div className="w-1/3 text-gray-700 font-medium">{approver.approverEmail}</div>
                      <div className="w-1/3 text-sm text-gray-600">{approver.status}</div>
                      {approver.message && (
                        <div className="w-1/3 text-sm italic text-gray-500 truncate">
                          {approver.message}
                        </div>
                      )}
                    </div>
                ))}
              </div>
            </div>
          </div>
        )}

      </div>
    );
  }
