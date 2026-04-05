// AUTO-GENERATED. DO NOT EDIT.
import useApexClass from '../useApexClass';
import { useMemo } from 'react';
import type { Bridge } from '../../types';

export function useApexChessDashboardController(bridge: Bridge): {
    getAccountIndustries: () => Promise<any>,
    getAccounts: () => Promise<any>,
    getAccountTypes: () => Promise<any>
  } {
  const apexClass = useApexClass(bridge, 'ChessDashboardController');
  return useMemo(() => ({
    getAccountIndustries: () => apexClass.mutate('getAccountIndustries', {}),
    getAccounts: () => apexClass.mutate('getAccounts', {}),
    getAccountTypes: () => apexClass.mutate('getAccountTypes', {})
  }), [apexClass]);
}
