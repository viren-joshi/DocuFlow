import { Auth } from 'aws-amplify';
import { FiLogOut } from 'react-icons/fi'; // logout icon

function Header({ showSignOut = false }) {
  const handleSignOut = async () => {
    await Auth.signOut();
    window.location.href = '/login'; // or use navigate() if you're using react-router
  };

  return (
    <header className="bg-transparent shadow-md py-4 px-6 flex justify-between items-center rounded-xl shadow-none">   
      <h1 className="text-xl font-semibold text-gray-800">DocuFlow</h1>
      {showSignOut && (
        <button onClick={handleSignOut} title="Sign Out">
          <FiLogOut className="text-xl text-gray-600 hover:text-red-500" />
        </button>
      )}
    </header>
  );
}

export default Header;
