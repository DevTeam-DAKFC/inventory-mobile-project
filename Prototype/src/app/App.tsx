import { BrowserRouter, Routes, Route, Navigate } from 'react-router';
import { useState } from 'react';
import LoginScreen from './screens/LoginScreen';
import DashboardScreen from './screens/DashboardScreen';
import ProductsScreen from './screens/ProductsScreen';
import ProductDetailScreen from './screens/ProductDetailScreen';
import ProductFormScreen from './screens/ProductFormScreen';
import StockScreen from './screens/StockScreen';
import MovementFormScreen from './screens/MovementFormScreen';
import MovementsScreen from './screens/MovementsScreen';
import MovementDetailScreen from './screens/MovementDetailScreen';
import AlertsScreen from './screens/AlertsScreen';
import BranchesScreen from './screens/BranchesScreen';
import MobileLayout from './components/MobileLayout';

export default function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  return (
    <BrowserRouter>
      <Routes>
        <Route
          path="/login"
          element={
            isAuthenticated ? <Navigate to="/" replace /> : <LoginScreen onLogin={() => setIsAuthenticated(true)} />
          }
        />

        {isAuthenticated ? (
          <Route element={<MobileLayout />}>
            <Route path="/" element={<DashboardScreen />} />
            <Route path="/productos" element={<ProductsScreen />} />
            <Route path="/productos/nuevo" element={<ProductFormScreen />} />
            <Route path="/productos/:id" element={<ProductDetailScreen />} />
            <Route path="/productos/:id/editar" element={<ProductFormScreen />} />
            <Route path="/stock" element={<StockScreen />} />
            <Route path="/movimientos" element={<MovementsScreen />} />
            <Route path="/movimientos/nuevo" element={<MovementFormScreen />} />
            <Route path="/movimientos/:id" element={<MovementDetailScreen />} />
            <Route path="/alertas" element={<AlertsScreen />} />
            <Route path="/sucursales" element={<BranchesScreen />} />
          </Route>
        ) : (
          <Route path="*" element={<Navigate to="/login" replace />} />
        )}
      </Routes>
    </BrowserRouter>
  );
}
