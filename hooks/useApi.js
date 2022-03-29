import axios from "axios";
import { useQuery } from "react-query";

export function useApi(params) {
  const { url, payload } = params;
  if (!url) {
    throw new Error("No url specified");
  }
  const { isLoading, error, data } = useQuery(
    [params],
    async () => {
      // console.log("useQuery", {
      //   ...payload,
      // });
      const res = await axios.post(`/api/${url}`, {
        ...payload,
      });
      return res.data;
    },
    {
      keepPreviousData: true,
      staleTime: Infinity,
    }
  );

  return {
    isLoading,
    error,
    data,
  };
}
