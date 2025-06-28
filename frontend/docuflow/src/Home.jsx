
import { Auth } from 'aws-amplify';
import { useState } from 'react';
import Header from './Header';
import SubmittedDocuments from './SubmittedDocuments';
import ApproveDocuments from './ApproveDocuments';
import axiosClient from './api/axiosClient';

export default function Home() {
  const [activeTab, setActiveTab] = useState('submitted');
  const [isUploadModalOpen, setIsUploadModalOpen] = useState(false);
  const [file, setFile] = useState(null);
  const [approvers, setApprovers] = useState('');

  const handleUpload = async () => {
    if (!file || !approvers) {
      alert('Please select a file and enter approver emails.');
      return;
    }

    try {
      const user = await Auth.currentAuthenticatedUser();
      const userId = user.attributes.sub;

      // Step 1: Get presigned URL to upload
      const presignResp = await axiosClient.post('/getUploadDocumentUrl', {
        file_name : file.name
      });
      console.log(presignResp)

      const { url, file_name: s3FileName } = presignResp.data;

      // Step 2: Upload document to S3
      const uploadResponse = await fetch(url, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/pdf' },
        body: file,
      });

      if(!uploadResponse.ok) {
        alert(`S3 upload failed with status ${uploadResponse.status}`);
        return; // Stop the function if upload failed
      }

      // Step 3: Trigger Step Function to start approval
      await axiosClient.post('/submitDocument', {
        user_id: userId,
        file: s3FileName,
        approvers: approvers
          .split(',')
          .map((email) => email.trim())
          .filter((email) => email),
      });

      alert('Document submitted successfully!');
      setFile(null);
      setApprovers('');
      setIsUploadModalOpen(false);
    } catch (error) {
      console.error('Upload failed:', error);
      alert('Failed to upload document.');
    }
  };


  // const navigate = useNavigate();

  // const logout = async () => {
  //   await Auth.signOut();
  //   console.log('User logged out');
  //   navigate('/login');
  // };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-100 via-purple-100 to-pink-100 p-4">
      <Header showSignOut={true} />
      {/* Tab Switcher */}
      <div className="flex justify-between max-w-6xl space-x-3 mt-6 mb-10 min-w-0 mx-auto">
        <div className="flex space-x-3">
          <button
          onClick={() => setActiveTab('submitted')}
          className={`px-5 py-2 border-2 rounded-xl text-sm font-medium transition duration-200 ${
            activeTab === 'submitted'
              ? 'border-blue-600 text-blue-600'
              : 'border-gray-400 text-gray-700 hover:border-blue-500 hover:text-blue-500'
          }`}
        >
          Submitted Documents
        </button>
        <button
          onClick={() => setActiveTab('approve')}
          className={`px-5 py-2 border-2 rounded-xl text-sm font-medium transition duration-200 ${
            activeTab === 'approve'
              ? 'border-blue-600 text-blue-600'
              : 'border-gray-400 text-gray-700 hover:border-blue-500 hover:text-blue-500'
          }`}
        >
          Approve Documents
        </button>
        </div>
        
        <button
          onClick={() => setIsUploadModalOpen(true)}
          className="px-4 py-2 rounded-xl text-sm font-medium border-1 border-gray-400 text-gray-700 transition duration-200"
        >
          + New Document
        </button>
      </div>

      {/* Tab Content */}
      <div className="max-w-6xl mx-auto space-y-6">
        {activeTab === 'submitted' && <SubmittedDocuments />}
        {activeTab === 'approve' && <ApproveDocuments />}
      </div>
      {isUploadModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm flex items-center justify-center">
          <div className="bg-white rounded-lg p-6 max-w-md w-full relative space-y-4">
            <button
              onClick={() => setIsUploadModalOpen(false)}
              className="absolute top-2 right-3 text-gray-500 hover:text-red-500 text-xl font-bold"
            >
              &times;
            </button>

            <h2 className="text-lg font-semibold">Submit New Document</h2>

            <div className="space-y-2">
              <label className="block text-sm font-medium">Document (PDF):</label>
              <input
                type="file"
                accept="application/pdf"
                onChange={(e) => setFile(e.target.files[0])}
                className="w-full text-sm"
              />

              <label className="block text-sm font-medium">Approver Emails (comma-separated):</label>
              <textarea
                value={approvers}
                onChange={(e) => setApprovers(e.target.value)}
                rows="3"
                placeholder="email1@example.com, email2@example.com"
                className="w-full border rounded px-3 py-2 text-sm"
              />
            </div>

            <button
              onClick={handleUpload}
              className="mt-2 w-full bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
            >
              Submit Document
            </button>
          </div>
        </div>
      )}
    </div>
  );
}