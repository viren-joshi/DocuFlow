import { useEffect, useState } from 'react';
import { FaFileAlt } from 'react-icons/fa';
import axiosClient from './api/axiosClient';
import { Auth } from 'aws-amplify';
import cleanFileName from './CleanFileName';

export default function ApproveDocuments() {
  const [documents, setDocuments] = useState([]);
  const [selectedDoc, setSelectedDoc] = useState(null);
  const [previewUrl, setPreviewUrl] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [action, setAction] = useState('approve'); // or 'reject'
  const [message, setMessage] = useState('');
  const [newFile, setNewFile] = useState(null);

  useEffect(() => {
    const fetchDocs = async () => {
      const user = await Auth.currentAuthenticatedUser();
      const userId = user.attributes.sub;

      try {
        const response = await axiosClient.post('/getApprovalDocuments', { approver_id: userId });
        console.log(response.data);
        setDocuments(response.data.documents);
      } catch (error) {
        console.error('Error fetching approval documents:', error);
        setDocuments([]);
      }
    };

    fetchDocs();
  }, []);

  const handlePreview = async (doc) => {
    setSelectedDoc(doc);
    setMessage('');
    setAction('approve');
    setNewFile(null);

    try {
      const response = await axiosClient.post('/getViewDocumentUrl', {
        file_name: doc.documentId,
      });
      setPreviewUrl(response.data.url);
      setIsModalOpen(true);
    } catch (error) {
      console.error('Error getting view URL:', error);
    }
  };

  const handleSubmit = async () => {
  try {
    const user = await Auth.currentAuthenticatedUser();
    const userId = user.attributes.sub;
    const documentId = selectedDoc.documentId;

    // If new version is selected, upload it first to S3
    // TODO: Remove leading documents/ from documentId
    // TODO: check if old document is being updated or a new one is being uploaded.
    if (newFile) {
      const uploadUrlResp = await axiosClient.post('/getUploadDocumentUrl', {
        "file_name": documentId,
        "is_new": false
      });

      const uploadUrl = uploadUrlResp.data["url"];

      // Upload the new file to S3 using PUT
      await fetch(uploadUrl, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/pdf',
        },
        body: newFile,  
      });
    }

    console.log('Submitting approval:', {
      approverId: userId,
      documentId: documentId,
      isApproved: action === 'approve',
      message: message,
    });

    // Submit the approval action
    await axiosClient.post('/approveDocument', {
      approverId: userId,
      documentId: documentId,
      isApproved: action === 'approve',
      message: message,
    });

    alert('Response submitted successfully');
    setIsModalOpen(false);
  } catch (error) {
    console.error('Error during approval process:', error);
    alert('Failed to submit approval');
  }
};


  return (
    <div className="w-full space-y-2">
      {documents.length === 0 ? (
        <p className="text-center text-gray-500 py-8">No Documents To Approve</p>
      ) : (
        documents.map((doc) => (
          <div
            key={doc.documentId}
            className="flex items-center justify-between border-b border-gray-300 py-3"
          >
            <div className="flex flex-1 items-center gap-4">
              <span className="w-1/3 font-medium text-gray-800">{cleanFileName(doc.documentId)}</span>
              <span className="w-1/3 text-sm text-gray-500">{new Date(doc.submittedAt).toLocaleString()}</span>
              <span className="w-1/3 text-sm text-gray-500">{doc.submittedBy}</span>
            </div>
            <button
              onClick={() => handlePreview(doc)}
              className="text-blue-600 hover:text-blue-800 text-xl"
              title="View & Act"
            >
              <FaFileAlt
                className={`text-xl ${
                  doc.status === 'APPROVED' && doc.finalStatus === 'APPROVED'
                    ? 'text-green-600'
                    : doc.status === 'PENDING' || doc.finalStatus === 'PENDING'
                    ? 'text-yellow-500'
                    : 'text-red-600'
                } hover:text-black`}
              />
            </button>
          </div>
        ))
      )}

      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm flex items-center justify-center">
          <div className="bg-white rounded-lg p-6 max-w-3xl w-full relative pt-10 px-6 pb-6">
            <button
              onClick={() => setIsModalOpen(false)}
              className="absolute top-2 right-3 text-gray-500 hover:text-red-500 text-xl font-bold"
            >
              &times;
            </button>
            <iframe
              src={previewUrl}
              title="Document Preview"
              className="w-full h-[60vh] border rounded"
            />

            {selectedDoc?.status === 'PENDING' ? (
              <div className="space-y-2">
                <label className="block text-sm font-medium text-gray-700">Upload New Version (optional):</label>
                <input
                  type="file"
                  accept="application/pdf"
                  onChange={(e) => setNewFile(e.target.files[0])}
                  className="block w-full text-sm text-gray-700"
                />

                <label className="block text-sm font-medium text-gray-700">Message:</label>
                <textarea
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  rows="3"
                  className="w-full border rounded px-3 py-2 text-sm"
                />

                <div className="flex items-center gap-6">
                  <label className="flex items-center gap-2">
                    <input
                      type="radio"
                      name="action"
                      value="approve"
                      checked={action === 'approve'}
                      onChange={() => setAction('approve')}
                    />
                    Approve
                  </label>
                  <label className="flex items-center gap-2">
                    <input
                      type="radio"
                      name="action"
                      value="reject"
                      checked={action === 'reject'}
                      onChange={() => setAction('reject')}
                    />
                    Reject
                  </label>
                </div>

                <button
                  onClick={handleSubmit}
                  className="mt-3 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                >
                  Submit
                </button>
              </div>
            ) : (
              <div className="space-y-2 text-sm text-gray-700">
                <div><strong>Status: </strong> {selectedDoc.status}</div>
                {selectedDoc.message?.trim() && (
                  <div><strong>Message: </strong> “{selectedDoc.message}”</div>
                )}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
